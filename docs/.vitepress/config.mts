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
      { text: 'Getting Started', link: '/getting-started/quick-start' },
      { text: 'Usage', link: '/usage/controller' },
      { text: 'Hardware', link: '/hardware/choosing-hardware' },
      { text: 'Software', link: '/software/flashing' },
      { text: 'Audio', link: '/features/pipelines' },
      { text: 'Developers', link: '/advanced/architecture' },
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
          { text: 'Architecture & Software Components', link: '/advanced/architecture' },
          { text: 'Hardware API', link: '/advanced/hardware-api' },
          { text: 'Bleno Service (BLE WiFi Provisioning)', link: '/advanced/bleno' },
          { text: 'Network Debugging Guide', link: '/advanced/troubleshooting/network-debugging' },


        ]
      }
    ],

    socialLinks: [
      { icon: 'github', link: 'https://github.com/byrdsandbytes/beatnik-pi' },
      {
        icon: {
          svg: '<svg role="img" viewBox="0 0 24 24" xmlns="http://www.w3.org/2000/svg"><title>Reddit</title><path d="M12 0C5.373 0 0 5.373 0 12c0 3.314 1.343 6.314 3.515 8.485l-2.286 2.286C.775 23.225 1.097 24 1.738 24H12c6.627 0 12-5.373 12-12S18.627 0 12 0Zm4.388 3.199c1.104 0 1.999.895 1.999 1.999 0 1.105-.895 2-1.999 2-.946 0-1.739-.657-1.947-1.539v.002c-1.147.162-2.032 1.15-2.032 2.341v.007c1.776.067 3.4.567 4.686 1.363.473-.363 1.064-.58 1.707-.58 1.547 0 2.802 1.254 2.802 2.802 0 1.117-.655 2.081-1.601 2.531-.088 3.256-3.637 5.876-7.997 5.876-4.361 0-7.905-2.617-7.998-5.87-.954-.447-1.614-1.415-1.614-2.538 0-1.548 1.255-2.802 2.803-2.802.645 0 1.239.218 1.712.585 1.275-.79 2.881-1.291 4.64-1.365v-.01c0-1.663 1.263-3.034 2.88-3.207.188-.911.993-1.595 1.959-1.595Zm-8.085 8.376c-.784 0-1.459.78-1.506 1.797-.047 1.016.64 1.429 1.426 1.429.786 0 1.371-.369 1.418-1.385.047-1.017-.553-1.841-1.338-1.841Zm7.406 0c-.786 0-1.385.824-1.338 1.841.047 1.017.634 1.385 1.418 1.385.785 0 1.473-.413 1.426-1.429-.046-1.017-.721-1.797-1.506-1.797Zm-3.703 4.013c-.974 0-1.907.048-2.77.135-.147.015-.241.168-.183.305.483 1.154 1.622 1.964 2.953 1.964 1.33 0 2.47-.81 2.953-1.964.057-.137-.037-.29-.184-.305-.863-.087-1.795-.135-2.769-.135Z"/></svg>'
        },
        link: 'https://www.reddit.com/r/beatnikAudio/',
        ariaLabel: 'r/beatnikAudio on Reddit'
      }
    ]
  }
})
