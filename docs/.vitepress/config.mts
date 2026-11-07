import { defineConfig } from 'vitepress'

// https://vitepress.dev/reference/site-config
export default defineConfig({
  title: "Beatnik Pi",
  description: "Open Source Multi-Room Audio. Free. Customizable. Based on Raspberry Pi. Made in Bern, Switzerland.",
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
      { text: 'Examples', link: '/markdown-examples' },
      { text: 'beatnik.audio', link: 'https://beatnik.audio' }
    ],

    sidebar: [
      {
        text: 'Getting Started',
        items: [
          { text: 'Project Overview', link: '/getting-started/project-overview' },
          { text: 'Quick Start', link: '/getting-started/quick-start' }
        ]
      },
      {
        text: 'Usage',
        collapsed: false,
        items: [
          { text: 'Using the Beatnik Controller', link: '/usage/controller' },
          {
            text: 'Controller Guide',
            collapsed: false,
            items: [
              { text: 'Getting Around', link: '/usage/guide-getting-around' },
              { text: 'Everyday Use', link: '/usage/guide-everyday-use' },
              { text: 'Adding a New Device', link: '/usage/guide-add-device' },
              { text: 'Camilla DSP & Equalising', link: '/usage/guide-camilladsp' },
              { text: 'Maintenance & Updates', link: '/usage/guide-maintenance' },
              { text: 'Settings & Help', link: '/usage/guide-settings-help' }
            ]
          },
          { text: 'Controller Docker Setup', link: '/usage/controller-docker' }
        ]
      },
      {
        text: 'Hardware & Assembly',
        collapsed: false,
        items: [
          { text: 'Choosing the Right Hardware', link: '/hardware/choosing-hardware' },
          { text: 'Hardware Examples', link: '/hardware/overview' },
          { text: 'How to Build a Beatnik Amplifier', link: '/hardware/build-amplifier' }
        ]
      },
      {
        text: 'Software Setup',
        collapsed: false,
        items: [
          { text: 'Beatnik OS Installation Guide', link: '/software/flashing' },
          { text: 'Shell Script Installation Guide', link: '/software/shell-script' },
          { text: 'Manual / Bare Metal Installation', link: '/software/manual-installation' },
          {
            text: 'Soundcard Configuration (Bare Metal)',
            collapsed: true,
            items: [
              { text: 'HifiBerry Amp 4 Pro', link: '/software/soundcards/hifiberry-amp4Pro' },
              { text: 'HiFiBerry DAC 2 ADC Pro', link: '/software/soundcards/hifiberry-dac-adc-pro' },
              { text: 'HiFiBerry Digi+ Pro / Digi 2 Pro', link: '/software/soundcards/hifiberry-digi-pro' },
              { text: 'HiFiBerry Digi+ / Digi 2 Standard', link: '/software/soundcards/hifiberry-digi' },
              { text: 'IQ Audio DAC Pro', link: '/software/soundcards/iqaudio-dacPro' },
              { text: 'Raspberry Pi DAC+ HAT', link: '/software/soundcards/raspberry-dacPlus' },
              { text: 'Raspberry Pi DigiAmp+ HAT', link: '/software/soundcards/raspberry-digiAmpPlus' }
            ]
          },
          { text: 'Network and Infrastructure Requirements', link: '/software/network/requirements' }
        ]
      },
      {
        text: 'Audio & Streaming',
        collapsed: false,
        items: [
          { text: 'Beatnik Audio Pipelines', link: '/features/pipelines' },
          { text: 'AirPlay', link: '/features/streaming/airplay' },
          { text: 'Spotify Connect', link: '/features/streaming/spotify' },
          { text: 'Line-In', link: '/features/line-in' },
          { text: 'CamillaDSP', link: '/features/dsp' },
          { text: 'Snapserver Buffering', link: '/advanced/troubleshooting/snapserver-buffering' },
          { text: 'Snapserver Default Volume', link: '/features/streaming/snapserver-default-volume' }
        ]
      },
      {
        text: 'Developers',
        collapsed: true,
        items: [
          { text: 'Hardware API', link: '/advanced/hardware-api' },
          { text: 'Bleno Service (BLE WiFi Provisioning)', link: '/advanced/bleno' },
          { text: 'Network Debugging Guide', link: '/advanced/troubleshooting/network-debugging' },


        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/byrdsandbytes/beatnik-pi' }
    ]
  }
})
