import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Beatnik Pi",
  description: "Open Source Multi-Room Audio",
  markdown: {
    config: (md) => {
      md.core.ruler.push('resolve-readme-image-paths', (state) => {
        const rewriteImagePath = (token: (typeof state.tokens)[number]) => {
          if (token.type === 'image') {
            const src = token.attrGet('src')
            if (src?.startsWith('docs/images/')) {
              token.attrSet('src', src.replace(/^docs\//, '../'))
            }
          }

          if (token.type === 'link_open') {
            const href = token.attrGet('href')
            if (href?.startsWith('docs/')) {
              token.attrSet('href', href.replace(/^docs\//, '/'))
            }
          }

          if (token.type === 'html_block' || token.type === 'html_inline') {
            token.content = token.content.replace(
              /(src=["'])docs\/images\//g,
              '$1../images/'
            )
          }

          token.children?.forEach(rewriteImagePath)
        }

        state.tokens.forEach(rewriteImagePath)
      })
    }
  },
  themeConfig: {
    // https://vitepress.dev/reference/default-theme-config
    logo: {
      light: '/images/Beatnik_Logo_Word.svg',
      dark: '/images/Beatnik_Logo_Word_Neg.svg'
    },
    siteTitle: false,

    nav: [
      { text: 'Home', link: '/' },
      { text: 'Project Overview', link: '/getting-started/project-overview' },
      { text: 'Examples', link: '/markdown-examples' }
    ],

    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'Quick Start', link: '/getting-started/quick-start' },
          { text: 'Project Overview', link: '/getting-started/project-overview' }
        ]
      },
      {
        text: 'Hardware & Assembly',
        collapsed: false,
        items: [
          { text: 'HifiBerry Amp 4 Pro', link: '/hardware/soundcards/hifiberry-amp4Pro' },
          { text: 'HiFiBerry DAC 2 ADC Pro', link: '/hardware/soundcards/hifiberry-dac-adc-pro' },
          { text: 'HiFiBerry Digi+ Pro / Digi 2 Pro', link: '/hardware/soundcards/hifiberry-digi-pro' },
          { text: 'HiFiBerry Digi+ / Digi 2 Standard', link: '/hardware/soundcards/hifiberry-digi' },
          { text: 'IQ Audio DAC Pro', link: '/hardware/soundcards/iqaudio-dacPro' },
          { text: 'Raspberry Pi DAC+ HAT', link: '/hardware/soundcards/raspberry-dacPlus' },
          { text: 'Raspberry Pi DigiAmp+ HAT', link: '/hardware/soundcards/raspberry-digiAmpPlus' }
        ]
      },
      {
        text: 'Software Setup',
        collapsed: false,
        items: [
          { text: 'Beatnik OS Installation Guide', link: '/software/flashing' },
          { text: 'Shell Script Installation Guide', link: '/software/shell-script' },
          { text: 'Manual / Bare Metal Installation', link: '/software/manual-installation' },
          { text: 'Network and Infrastructure Requirements', link: '/software/network/requirements' }
        ]
      },
      {
        text: 'Audio & Streaming',
        collapsed: false,
        items: [
          { text: 'Line-In', link: '/features/line-in' },
          { text: 'CamillaDSP', link: '/features/dsp' },
          { text: 'Snapserver Buffering', link: '/advanced/troubleshooting/snapserver-buffering' },
          { text: 'Snapserver Default Volume', link: '/features/streaming/snapserver-default-volume' }
        ]
      },
      {
        text: 'Developers & Support',
        collapsed: true,
        items: [
          { text: 'Network Debugging Guide', link: '/advanced/troubleshooting/network-debugging' },
          { text: 'Runtime API Examples', link: '/api-examples' },
          { text: 'Markdown Extension Examples', link: '/markdown-examples' }
        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/byrdsandbytes/beatnik-pi' }
    ]
  }
})
