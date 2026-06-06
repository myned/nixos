const battery = await Service.import('battery')
const audio = await Service.import('audio')
const hyprland = await Service.import('hyprland')
const mpris = await Service.import('mpris')
const notifications = await Service.import('notifications')
const systemtray = await Service.import('systemtray')

/// WORKSPACES ///

const Workspaces = () => Widget.EventBox({
  onScrollDown: () => hyprland.messageAsync(`dispatch workspace -1`),
  onScrollUp: () => hyprland.messageAsync(`dispatch workspace +1`),

  child: Widget.Box({
    spacing: 8,

    //?? Increase length if workspaces > 10
    children: Array.from({ length: 10 }, (_, i) => i + 1).map(i => Widget.Button({
      onClicked: () => hyprland.messageAsync(`dispatch workspace ${i}`),

      attribute: i,
      label: `${i}`,
    })),

    // Initial button visibility
    setup: self => self.hook(hyprland, () => self.children.forEach(btn => {
      btn.visible = hyprland.workspaces.some(ws => ws.id === btn.attribute)
    })),
  }),
})

/// CLOCK ///

const Clock = () => Widget.Label({
  class_name: 'clock',

  setup: self => self.poll(1000, self =>
    Utils.execAsync(['date', '+%a %b %d  %I:%M %p'])
      .then(date => self.label = date)),
})

/// NOTIFICATIONS ///

const Notification = () => Widget.Box({
  class_name: 'notification',
  visible: notifications.bind('popups').transform(p => p.length > 0),
  children: [
    Widget.Icon({
      icon: 'preferences-system-notifications-symbolic',
    }),
    Widget.Label({
      label: notifications.bind('popups').transform(p => p[0]?.summary || ''),
    }),
  ],
})

/// PLAYER ///

const Media = () => Widget.Button({
  class_name: 'media',
  on_primary_click: () => mpris.getPlayer('')?.playPause(),
  on_scroll_up: () => mpris.getPlayer('')?.next(),
  on_scroll_down: () => mpris.getPlayer('')?.previous(),
  child: Widget.Label('-').hook(mpris, self => {
    if (mpris.players[0]) {
      const { track_artists, track_title } = mpris.players[0]
      self.label = `${track_artists.join(', ')} - ${track_title}`
    } else {
      self.label = 'Nothing is playing'
    }
  }, 'player-changed'),
})

/// VOLUME ///
console.log(audio.speaker)
const Volume = () => Widget.Button({
  on_clicked: () => audio.speaker.is_muted = !audio.speaker.is_muted,

  child: Widget.Icon().hook(audio.speaker, self => {
    const icon = [
      [101, 'overamplified'],
      [67, 'high'],
      [34, 'medium'],
      [0, 'low'],
    ].find(([threshold]) => threshold <= audio.speaker.volume * 100)?.[1]

    self.icon = `audio-volume-${icon}-symbolic`
    self.tooltip_text = `Volume ${Math.floor(audio.speaker.volume * 100)}%`
  }),
})

/// BATTERY ///

const Battery = () => Widget.Box({
  spacing: 4,
  class_name: battery.bind('charging').transform(c => c ? 'charging' : ''),
  visible: battery.bind('available'),

  children: [
    // Battery icon
    Widget.Icon({
      icon: battery.bind('percent').transform(p => `battery-level-${Math.floor(p / 10) * 10}-symbolic`),
    }),

    // Battery discharge wattage
    Widget.Label({
      label: battery.bind('energy-rate').transform(e => `${Math.round(e)}W`),
    }),
  ],
})

/// TRAY ///

const SysTray = () => Widget.Box({
  children: systemtray.bind('items').transform(items => {
    return items.map(item => Widget.Button({
      child: Widget.Icon({ binds: [['icon', item, 'icon']] }),
      on_primary_click: (_, event) => item.activate(event),
      on_secondary_click: (_, event) => item.openMenu(event),
      binds: [['tooltip-markup', item, 'tooltip-markup']],
    }))
  }),
})

/// LAYOUT ///

const Left = () => Widget.Box({
  spacing: 8,
  children: [
    Workspaces(),
  ],
})

const Center = () => Widget.Box({
  spacing: 8,
  children: [
    Clock(),
    Notification(),
  ],
})

const Right = () => Widget.Box({
  hpack: 'end',
  spacing: 8,
  children: [
    Media(),
    SysTray(),
    Volume(),
    Battery(),
  ],
})

const Bar = (monitor = 0) => Widget.Window({
  monitor,
  name: `bar${monitor}`,
  class_name: 'bar',
  anchor: ['top', 'left', 'right'],
  exclusivity: 'exclusive',

  child: Widget.EventBox({
    on_scroll_up: () => audio['speaker'].volume = audio['speaker'].volume + 1,
    on_scroll_down: () => audio['speaker'].volume = audio['speaker'].volume + 1,

    child: Widget.CenterBox({
      spacing: 8,
      start_widget: Left(),
      center_widget: Center(),
      end_widget: Right(),
    }),
  })
})

/// EXPORTS ///

export default {
  style: './style.css',
  windows: [Bar()],
}
