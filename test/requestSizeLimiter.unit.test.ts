import { beforeEach, describe, expect, it, vi } from 'vitest'

const state = vi.hoisted(() => ({
  config: vi.fn(),
  headers: {} as Record<string, string>,
  enabled: true
}))
vi.mock('nitropack/runtime', () => ({ useRuntimeConfig: state.config.mockReturnValue({ security: { strict: false } }) }))
vi.mock('../src/runtime/nitro/context', () => ({
  resolveSecurityRules: () => ({ enabled: state.enabled, requestSizeLimiter: { maxRequestSizeInBytes: 100, maxUploadFileRequestInBytes: 1000 } })
}))
vi.mock('h3', () => ({
  defineEventHandler: (handler: unknown) => handler,
  getRequestHeader: (_event: unknown, key: string) => state.headers[key],
  createError: (error: { statusCode: number }) => Object.assign(new Error('too large'), error)
}))
import handler from '../src/runtime/server/middleware/requestSizeLimiter'

const event = { node: { req: { method: 'POST' } }, context: {} } as Parameters<typeof handler>[0]
describe('request size config lifecycle / 請求大小設定生命週期', () => {
  it('does not read runtime config at import time', () => { expect(state.config).not.toHaveBeenCalled() })
  beforeEach(() => { state.headers = {}; state.enabled = true })

  it('uses the event config and rejects a declared oversized request', () => {
    state.headers['content-length'] = '101'
    expect(() => handler(event)).toThrow(expect.objectContaining({ statusCode: 413 }))
    expect(state.config).toHaveBeenCalledWith(event)
  })

  it('keeps the separate multipart limit', () => {
    state.headers = { 'content-length': '101', 'content-type': 'multipart/form-data; boundary=test' }
    expect(handler(event)).toBeUndefined()
    state.headers['content-length'] = '1001'
    expect(() => handler(event)).toThrow(expect.objectContaining({ statusCode: 413 }))
  })

  it('respects the disabled security option', () => {
    state.enabled = false
    state.headers['content-length'] = '1001'
    expect(handler(event)).toBeUndefined()
  })
})
