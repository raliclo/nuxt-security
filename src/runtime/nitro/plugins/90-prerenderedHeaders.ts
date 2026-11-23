import { defineNitroPlugin, useStorage } from 'nitropack/runtime'
import { getResponseHeaders, setResponseHeaders } from 'h3'
import type { OutgoingHttpHeaders } from 'http'
import { savePrerenderedHeaders } from '../../../utils/prerenderedHeaders'
import { resolveSecurityRules } from '../context'

/**
 * This plugin saves and retrieves prerendered headers in SSG mode.
 */
export default defineNitroPlugin(async(nitroApp) => {
  // Save prerendered headers when in SSG mode
  if (import.meta.prerender) {
    const prerenderedHeaders: Record<string, OutgoingHttpHeaders> = {}
    nitroApp.hooks.hook('render:html', (_, { event }) => {
      const rules = resolveSecurityRules(event)
      if (rules.enabled && rules.ssg && rules.ssg.nitroHeaders) {
        // We save the headers for the current path
        const headers = getResponseHeaders(event)
        const path = event.path.split('?')[0]
        if (!path) return
        // This is a hack
        // It works because headers is an object
        // 70-securityHeaders is executed after this step
        // And will modify that headers object
        prerenderedHeaders[path] = headers
      }
    })

    nitroApp.hooks.hook('close', async() => {
      await savePrerenderedHeaders(prerenderedHeaders, useStorage('build:nuxt-security'))
    })
  }

  // Retrieve prerendered headers when in SSR mode
  else {
    const prerenderedHeaders = await useStorage('assets:nuxt-security').getItem<Record<string, Record<string, string>>>('headers.json') || {}
    nitroApp.hooks.hook('beforeResponse', (event) => {
      const rules = resolveSecurityRules(event)
      if (rules.enabled && rules.ssg && rules.ssg.nitroHeaders) {
        const path = event.path.split('?')[0]
        // We retrieve the headers for the current path
        if (path && prerenderedHeaders[path]) {
          setResponseHeaders(event, prerenderedHeaders[path])
        }
      }
    })
  }
})
