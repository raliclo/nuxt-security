import { defineEventHandler, createError, setResponseHeader, getRequestIP, getRequestHeader } from 'h3'
import { useStorage } from 'nitropack/runtime'
import type { H3Event } from 'h3'
import { resolveSecurityRoute, resolveSecurityRules } from '../../nitro/context'
import type { RateLimiter } from '../../../types/middlewares'
import { defaultSecurityConfig } from '../../../defaultConfig'
import defu from 'defu'
import { generateHash } from '../../../utils/crypto'
import { useRuntimeConfig } from 'nitropack/runtime'

const getDefaults = (event: Parameters<typeof useRuntimeConfig>[0]) => {
  const strict = useRuntimeConfig(event).security?.strict ?? false
  return defaultSecurityConfig('', strict).rateLimiter as Required<RateLimiter>
}

type StorageItem = {
  value: number,
  date: number
}


export default defineEventHandler(async(event) => {
  // Disable rate limiter in prerender mode
  if (import.meta.prerender) {
    return
  }

  const rules = resolveSecurityRules(event)
  const route = resolveSecurityRoute(event)

  if (rules.enabled && rules.rateLimiter) {
    const rateLimiter = defu(
      rules.rateLimiter,
      getDefaults(event)
    )
    const ip = getIP(event, rateLimiter.ipHeader, rateLimiter.trustProxy)
    if(rateLimiter.whiteList && rateLimiter.whiteList.includes(ip)){
      return
    }
    // Opaque keys avoid collisions and invalid filesystem characters. / 避免鍵值碰撞及檔案系統非法字元。
    const url = (await generateHash(JSON.stringify([ip, route]), 'SHA-256')).replace(/\+/g, '-').replace(/\//g, '_').replace(/=/g, '')

    const storage = useStorage<StorageItem>('#rate-limiter-storage')
    let storageItem = await storage.getItem(url) as StorageItem | null

    if (storageItem && typeof storageItem !== 'object') { return }

    if (!storageItem || Date.now() >= storageItem.date + Number(rateLimiter.interval)) {
      storageItem = { value: rateLimiter.tokensPerInterval, date: Date.now() }
    }

    const timeForInterval = storageItem.date + Number(rateLimiter.interval)

    if (storageItem.value <= 0) {
      const tooManyRequestsError = {
        statusCode: 429,
        statusMessage: 'Too Many Requests'
      }

      if (rules.rateLimiter.headers) {
        setResponseHeader(event, 'x-ratelimit-remaining', 0)
        setResponseHeader(event, 'x-ratelimit-limit', rateLimiter.tokensPerInterval)
        setResponseHeader(event, 'x-ratelimit-reset', timeForInterval)
      }

      if (rateLimiter.throwError === false) {
        return tooManyRequestsError
      }
      throw createError(tooManyRequestsError)
    }

    const newStorageItem: StorageItem = { value: storageItem.value - 1, date: storageItem.date }

    await storage.setItem(url, newStorageItem)
    const currentItem = await storage.getItem(url)as StorageItem

    if (currentItem && rateLimiter.headers) {
      setResponseHeader(event, 'x-ratelimit-remaining', currentItem.value)
      setResponseHeader(event, 'x-ratelimit-limit', rateLimiter.tokensPerInterval)
      setResponseHeader(event, 'x-ratelimit-reset', timeForInterval)
    }
  }
})

function getIP (event: H3Event, customIpHeader?: string, trustProxy = false) {
  const ip = customIpHeader ? getRequestHeader(event, customIpHeader) || '' : getRequestIP(event, { xForwardedFor: trustProxy }) || ''
  return ip
}
