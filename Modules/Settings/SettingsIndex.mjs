// Settings search index
// Each entry contains: name, category, categoryName, section, keywords
// - name: The display name of the setting (must match exactly)
// - category: The category key used for navigation
// - categoryName: Human-readable category name for display
// - section: The section header within the category
// - keywords: Additional search terms for better discoverability

export const settingsIndex = [
  // GENERAL CATEGORY
  // General section
  {
    name: "Logo",
    category: "general",
    categoryName: "General",
    section: "General",
    keywords: ["branding", "icon", "image"],
  },
  {
    name: "Wallpaper path",
    category: "general",
    categoryName: "General",
    section: "General",
    keywords: ["background", "image", "path"],
  },
  {
    name: "Desktop icons",
    category: "general",
    categoryName: "General",
    section: "General",
    keywords: ["icons", "desktop", "show"],
  },
  // Color section
  {
    name: "Scheme mode",
    category: "general",
    categoryName: "General",
    section: "Color",
    keywords: ["dark mode", "light mode", "theme", "color scheme"],
  },
  {
    name: "Scheme type",
    category: "general",
    categoryName: "General",
    section: "Color",
    keywords: [
      "vibrant",
      "expressive",
      "monochrome",
      "neutral",
      "tonal",
      "fidelity",
      "content",
      "rainbow",
      "fruit salad",
    ],
  },
  {
    name: "Automatic color scheme",
    category: "general",
    categoryName: "General",
    section: "Color",
    keywords: ["auto", "wallpaper", "generate", "color"],
  },
  {
    name: "Smart color scheme",
    category: "general",
    categoryName: "General",
    section: "Color",
    keywords: ["intelligent", "adaptive", "color"],
  },
  {
    name: "Schedule dark mode",
    category: "general",
    categoryName: "General",
    section: "Color",
    keywords: ["dark mode", "night", "time", "schedule", "automatic"],
  },
  {
    name: "Schedule Hyprsunset",
    category: "general",
    categoryName: "General",
    section: "Color",
    keywords: ["night light", "blue light", "temperature", "warm", "schedule"],
  },
  // Default Apps section
  {
    name: "Terminal",
    category: "general",
    categoryName: "General",
    section: "Default Apps",
    keywords: ["console", "command", "shell", "default app"],
  },
  {
    name: "Audio",
    category: "general",
    categoryName: "General",
    section: "Default Apps",
    keywords: ["sound", "volume", "mixer", "default app"],
  },
  {
    name: "Playback",
    category: "general",
    categoryName: "General",
    section: "Default Apps",
    keywords: ["media", "player", "music", "video", "default app"],
  },
  {
    name: "Explorer",
    category: "general",
    categoryName: "General",
    section: "Default Apps",
    keywords: ["file manager", "files", "browser", "default app"],
  },

  // WALLPAPER CATEGORY
  {
    name: "Enable wallpaper rendering",
    category: "wallpaper",
    categoryName: "Wallpaper",
    section: "Wallpaper",
    keywords: ["background", "enable", "show"],
  },
  {
    name: "Fade duration",
    category: "wallpaper",
    categoryName: "Wallpaper",
    section: "Wallpaper",
    keywords: ["transition", "animation", "crossfade"],
  },

  // BAR CATEGORY
  // Bar section
  {
    name: "Auto hide",
    category: "bar",
    categoryName: "Bar",
    section: "Bar",
    keywords: ["hide", "visibility", "autohide", "panel"],
  },
  {
    name: "Height",
    category: "bar",
    categoryName: "Bar",
    section: "Bar",
    keywords: ["size", "panel", "thickness"],
  },
  {
    name: "Rounding",
    category: "bar",
    categoryName: "Bar",
    section: "Bar",
    keywords: ["corners", "radius", "rounded"],
  },
  {
    name: "Border",
    category: "bar",
    categoryName: "Bar",
    section: "Bar",
    keywords: ["outline", "stroke", "edge"],
  },
  // Popouts section
  {
    name: "Tray",
    category: "bar",
    categoryName: "Bar",
    section: "Popouts",
    keywords: ["system tray", "icons", "popout"],
  },
  {
    name: "Audio",
    category: "bar",
    categoryName: "Bar",
    section: "Popouts",
    keywords: ["sound", "volume", "popout"],
  },
  {
    name: "Active window",
    category: "bar",
    categoryName: "Bar",
    section: "Popouts",
    keywords: ["window title", "current", "popout"],
  },
  {
    name: "Resources",
    category: "bar",
    categoryName: "Bar",
    section: "Popouts",
    keywords: ["cpu", "memory", "usage", "popout"],
  },
  {
    name: "Clock",
    category: "bar",
    categoryName: "Bar",
    section: "Popouts",
    keywords: ["time", "date", "popout"],
  },
  {
    name: "Network",
    category: "bar",
    categoryName: "Bar",
    section: "Popouts",
    keywords: ["wifi", "internet", "connection", "popout"],
  },
  {
    name: "Power",
    category: "bar",
    categoryName: "Bar",
    section: "Popouts",
    keywords: ["battery", "upower", "charging", "popout"],
  },
  // Entries section
  {
    name: "Bar entries",
    category: "bar",
    categoryName: "Bar",
    section: "Entries",
    keywords: ["modules", "widgets", "items", "order"],
  },
  // Dock section
  {
    name: "Enable dock",
    category: "bar",
    categoryName: "Bar",
    section: "Dock",
    keywords: ["taskbar", "show", "visibility"],
  },
  {
    name: "Dock height",
    category: "bar",
    categoryName: "Bar",
    section: "Dock",
    keywords: ["size", "taskbar", "thickness"],
  },
  {
    name: "Hover to reveal",
    category: "bar",
    categoryName: "Bar",
    section: "Dock",
    keywords: ["autohide", "mouse", "show"],
  },
  {
    name: "Pin on startup",
    category: "bar",
    categoryName: "Bar",
    section: "Dock",
    keywords: ["always visible", "pinned", "show"],
  },
  {
    name: "Pinned apps",
    category: "bar",
    categoryName: "Bar",
    section: "Dock",
    keywords: ["favorites", "applications", "shortcuts"],
  },
  {
    name: "Ignored app regexes",
    category: "bar",
    categoryName: "Bar",
    section: "Dock",
    keywords: ["filter", "exclude", "hide", "regex"],
  },

  // LOCKSCREEN CATEGORY
  {
    name: "Recolor logo",
    category: "lockscreen",
    categoryName: "Lockscreen",
    section: "Lockscreen",
    keywords: ["logo", "color", "tint"],
  },
  {
    name: "Enable fingerprint",
    category: "lockscreen",
    categoryName: "Lockscreen",
    section: "Lockscreen",
    keywords: ["fprint", "biometric", "unlock"],
  },
  {
    name: "Max fingerprint tries",
    category: "lockscreen",
    categoryName: "Lockscreen",
    section: "Lockscreen",
    keywords: ["attempts", "limit", "fprint"],
  },
  {
    name: "Blur amount",
    category: "lockscreen",
    categoryName: "Lockscreen",
    section: "Lockscreen",
    keywords: ["background", "blur", "effect"],
  },
  {
    name: "Height multiplier",
    category: "lockscreen",
    categoryName: "Lockscreen",
    section: "Lockscreen",
    keywords: ["size", "scale", "height"],
  },
  {
    name: "Aspect ratio",
    category: "lockscreen",
    categoryName: "Lockscreen",
    section: "Lockscreen",
    keywords: ["ratio", "width", "height"],
  },
  {
    name: "Center width",
    category: "lockscreen",
    categoryName: "Lockscreen",
    section: "Lockscreen",
    keywords: ["size", "width", "center"],
  },
  {
    name: "Idle Monitors",
    category: "lockscreen",
    categoryName: "Lockscreen",
    section: "Idle",
    keywords: ["timeout", "sleep", "idle", "lock", "suspend"],
  },

  // SERVICES CATEGORY
  // Services section
  {
    name: "Weather location",
    category: "services",
    categoryName: "Services",
    section: "Services",
    keywords: ["city", "location", "weather"],
  },
  {
    name: "Use Fahrenheit",
    category: "services",
    categoryName: "Services",
    section: "Services",
    keywords: ["temperature", "celsius", "units"],
  },
  {
    name: "Use twelve hour clock",
    category: "services",
    categoryName: "Services",
    section: "Services",
    keywords: ["time", "format", "12h", "24h", "am pm"],
  },
  {
    name: "Enable ddcutil service",
    category: "services",
    categoryName: "Services",
    section: "Services",
    keywords: ["monitor", "brightness", "ddc"],
  },
  {
    name: "GPU type",
    category: "services",
    categoryName: "Services",
    section: "Services",
    keywords: ["graphics", "nvidia", "amd", "intel"],
  },
  // Media section
  {
    name: "Audio increment",
    category: "services",
    categoryName: "Services",
    section: "Media",
    keywords: ["volume", "step", "increment"],
  },
  {
    name: "Brightness increment",
    category: "services",
    categoryName: "Services",
    section: "Media",
    keywords: ["screen", "step", "increment"],
  },
  {
    name: "Max volume",
    category: "services",
    categoryName: "Services",
    section: "Media",
    keywords: ["audio", "limit", "maximum"],
  },
  {
    name: "Default player",
    category: "services",
    categoryName: "Services",
    section: "Media",
    keywords: ["music", "media", "mpris"],
  },
  {
    name: "Visualizer bars",
    category: "services",
    categoryName: "Services",
    section: "Media",
    keywords: ["audio", "visualization", "cava"],
  },
  {
    name: "Player aliases",
    category: "services",
    categoryName: "Services",
    section: "Media",
    keywords: ["mpris", "rename", "alias"],
  },

  // NOTIFICATIONS CATEGORY
  // Notifications section
  {
    name: "Expire notifications",
    category: "notifications",
    categoryName: "Notifications",
    section: "Notifications",
    keywords: ["auto dismiss", "timeout", "expire"],
  },
  {
    name: "Default expire timeout",
    category: "notifications",
    categoryName: "Notifications",
    section: "Notifications",
    keywords: ["duration", "time", "dismiss"],
  },
  {
    name: "App notification cooldown",
    category: "notifications",
    categoryName: "Notifications",
    section: "Notifications",
    keywords: ["rate limit", "spam", "cooldown"],
  },
  {
    name: "Clear threshold",
    category: "notifications",
    categoryName: "Notifications",
    section: "Notifications",
    keywords: ["swipe", "dismiss", "threshold"],
  },
  {
    name: "Expand threshold",
    category: "notifications",
    categoryName: "Notifications",
    section: "Notifications",
    keywords: ["swipe", "expand", "threshold"],
  },
  {
    name: "Action on click",
    category: "notifications",
    categoryName: "Notifications",
    section: "Notifications",
    keywords: ["click", "action", "default"],
  },
  {
    name: "Group preview count",
    category: "notifications",
    categoryName: "Notifications",
    section: "Notifications",
    keywords: ["group", "stack", "preview"],
  },
  // Sizes section
  {
    name: "Width",
    category: "notifications",
    categoryName: "Notifications",
    section: "Sizes",
    keywords: ["notification", "size", "width"],
  },
  {
    name: "Image size",
    category: "notifications",
    categoryName: "Notifications",
    section: "Sizes",
    keywords: ["notification", "image", "icon"],
  },
  {
    name: "Badge size",
    category: "notifications",
    categoryName: "Notifications",
    section: "Sizes",
    keywords: ["notification", "badge", "app icon"],
  },

  // SIDEBAR CATEGORY
  {
    name: "Enable sidebar",
    category: "sidebar",
    categoryName: "Sidebar",
    section: "Sidebar",
    keywords: ["show", "panel", "side"],
  },
  {
    name: "Width",
    category: "sidebar",
    categoryName: "Sidebar",
    section: "Sidebar",
    keywords: ["size", "panel", "width"],
  },

  // UTILITIES CATEGORY
  // Utilities section
  {
    name: "Enable utilities",
    category: "utilities",
    categoryName: "Utilities",
    section: "Utilities",
    keywords: ["show", "enable"],
  },
  {
    name: "Max toasts",
    category: "utilities",
    categoryName: "Utilities",
    section: "Utilities",
    keywords: ["notifications", "limit", "maximum"],
  },
  {
    name: "Panel width",
    category: "utilities",
    categoryName: "Utilities",
    section: "Utilities",
    keywords: ["size", "width"],
  },
  {
    name: "Toast width",
    category: "utilities",
    categoryName: "Utilities",
    section: "Utilities",
    keywords: ["notification", "size", "width"],
  },
  // Toasts section
  {
    name: "Config loaded",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "config"],
  },
  {
    name: "Charging changed",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "battery", "power"],
  },
  {
    name: "Game mode changed",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "gaming"],
  },
  {
    name: "Do not disturb changed",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "dnd", "quiet"],
  },
  {
    name: "Audio output changed",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "speaker", "headphones"],
  },
  {
    name: "Audio input changed",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "microphone"],
  },
  {
    name: "Caps lock changed",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "keyboard"],
  },
  {
    name: "Num lock changed",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "keyboard"],
  },
  {
    name: "Keyboard layout changed",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "language", "input"],
  },
  {
    name: "VPN changed",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "vpn", "network"],
  },
  {
    name: "Now playing",
    category: "utilities",
    categoryName: "Utilities",
    section: "Toasts",
    keywords: ["toast", "notification", "music", "media"],
  },
  // VPN section
  {
    name: "Enable VPN integration",
    category: "utilities",
    categoryName: "Utilities",
    section: "VPN",
    keywords: ["vpn", "network", "connection"],
  },
  {
    name: "Provider",
    category: "utilities",
    categoryName: "Utilities",
    section: "VPN",
    keywords: ["vpn", "service", "provider"],
  },

  // DASHBOARD CATEGORY
  // Dashboard section
  {
    name: "Enable dashboard",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Dashboard",
    keywords: ["show", "enable", "panel"],
  },
  {
    name: "Media update interval",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Dashboard",
    keywords: ["refresh", "interval", "music"],
  },
  {
    name: "Resource update interval",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Dashboard",
    keywords: ["refresh", "interval", "cpu", "memory"],
  },
  {
    name: "Drag threshold",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Dashboard",
    keywords: ["swipe", "gesture", "threshold"],
  },
  // Performance section
  {
    name: "Show battery",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Performance",
    keywords: ["power", "battery", "visibility"],
  },
  {
    name: "Show GPU",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Performance",
    keywords: ["graphics", "gpu", "visibility"],
  },
  {
    name: "Show CPU",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Performance",
    keywords: ["processor", "cpu", "visibility"],
  },
  {
    name: "Show memory",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Performance",
    keywords: ["ram", "memory", "visibility"],
  },
  {
    name: "Show storage",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Performance",
    keywords: ["disk", "storage", "visibility"],
  },
  {
    name: "Show network",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Performance",
    keywords: ["internet", "network", "visibility"],
  },
  // Layout Sizes section (read-only)
  {
    name: "Tab indicator height",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "tab", "indicator"],
  },
  {
    name: "Tab indicator spacing",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "tab", "spacing"],
  },
  {
    name: "Info width",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "info", "width"],
  },
  {
    name: "Info icon size",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "icon"],
  },
  {
    name: "Date time width",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "clock", "date"],
  },
  {
    name: "Media width",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "music", "player"],
  },
  {
    name: "Media progress sweep",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "progress", "arc"],
  },
  {
    name: "Media progress thickness",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "progress", "stroke"],
  },
  {
    name: "Resource progress thickness",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "progress", "stroke"],
  },
  {
    name: "Weather width",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "weather"],
  },
  {
    name: "Media cover art size",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "album", "artwork"],
  },
  {
    name: "Media visualiser size",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "visualizer", "cava"],
  },
  {
    name: "Resource size",
    category: "dashboard",
    categoryName: "Dashboard",
    section: "Layout Sizes",
    keywords: ["size", "cpu", "memory"],
  },

  // APPEARANCE CATEGORY
  // Scale section
  {
    name: "Rounding scale",
    category: "appearance",
    categoryName: "Appearance",
    section: "Scale",
    keywords: ["corners", "radius", "scale"],
  },
  {
    name: "Spacing scale",
    category: "appearance",
    categoryName: "Appearance",
    section: "Scale",
    keywords: ["gap", "margin", "scale"],
  },
  {
    name: "Padding scale",
    category: "appearance",
    categoryName: "Appearance",
    section: "Scale",
    keywords: ["padding", "inset", "scale"],
  },
  {
    name: "Font size scale",
    category: "appearance",
    categoryName: "Appearance",
    section: "Scale",
    keywords: ["text", "font", "scale"],
  },
  {
    name: "Animation duration scale",
    category: "appearance",
    categoryName: "Appearance",
    section: "Scale",
    keywords: ["animation", "speed", "duration"],
  },
  // Fonts section
  {
    name: "Sans family",
    category: "appearance",
    categoryName: "Appearance",
    section: "Fonts",
    keywords: ["font", "typeface", "sans-serif"],
  },
  {
    name: "Monospace family",
    category: "appearance",
    categoryName: "Appearance",
    section: "Fonts",
    keywords: ["font", "typeface", "mono", "code"],
  },
  {
    name: "Material family",
    category: "appearance",
    categoryName: "Appearance",
    section: "Fonts",
    keywords: ["font", "icons", "material"],
  },
  {
    name: "Clock family",
    category: "appearance",
    categoryName: "Appearance",
    section: "Fonts",
    keywords: ["font", "time", "clock"],
  },
  // Animation section
  {
    name: "Media GIF speed adjustment",
    category: "appearance",
    categoryName: "Appearance",
    section: "Animation",
    keywords: ["gif", "speed", "animation"],
  },
  {
    name: "Session GIF speed",
    category: "appearance",
    categoryName: "Appearance",
    section: "Animation",
    keywords: ["gif", "speed", "animation", "login"],
  },
  // Transparency section
  {
    name: "Enable transparency",
    category: "appearance",
    categoryName: "Appearance",
    section: "Transparency",
    keywords: ["opacity", "translucent", "blur"],
  },
  {
    name: "Base opacity",
    category: "appearance",
    categoryName: "Appearance",
    section: "Transparency",
    keywords: ["opacity", "alpha", "transparency"],
  },
  {
    name: "Layer opacity",
    category: "appearance",
    categoryName: "Appearance",
    section: "Transparency",
    keywords: ["opacity", "alpha", "layers"],
  },

  // OSD CATEGORY
  // On Screen Display section
  {
    name: "Enable OSD",
    category: "osd",
    categoryName: "On screen display",
    section: "On Screen Display",
    keywords: ["show", "enable", "overlay"],
  },
  {
    name: "Hide delay",
    category: "osd",
    categoryName: "On screen display",
    section: "On Screen Display",
    keywords: ["timeout", "duration", "dismiss"],
  },
  {
    name: "Enable brightness OSD",
    category: "osd",
    categoryName: "On screen display",
    section: "On Screen Display",
    keywords: ["screen", "brightness", "overlay"],
  },
  {
    name: "Enable microphone OSD",
    category: "osd",
    categoryName: "On screen display",
    section: "On Screen Display",
    keywords: ["mic", "audio", "overlay"],
  },
  {
    name: "Brightness on all monitors",
    category: "osd",
    categoryName: "On screen display",
    section: "On Screen Display",
    keywords: ["multi-monitor", "all screens"],
  },
  // Sizes section
  {
    name: "Slider width",
    category: "osd",
    categoryName: "On screen display",
    section: "Sizes",
    keywords: ["size", "osd", "width"],
  },
  {
    name: "Slider height",
    category: "osd",
    categoryName: "On screen display",
    section: "Sizes",
    keywords: ["size", "osd", "height"],
  },

  // LAUNCHER CATEGORY
  // Launcher section
  {
    name: "Max apps shown",
    category: "launcher",
    categoryName: "Launcher",
    section: "Launcher",
    keywords: ["limit", "apps", "search results"],
  },
  {
    name: "Max wallpapers shown",
    category: "launcher",
    categoryName: "Launcher",
    section: "Launcher",
    keywords: ["limit", "wallpapers", "search results"],
  },
  {
    name: "Action prefix",
    category: "launcher",
    categoryName: "Launcher",
    section: "Launcher",
    keywords: ["command", "prefix", "action"],
  },
  {
    name: "Special prefix",
    category: "launcher",
    categoryName: "Launcher",
    section: "Launcher",
    keywords: ["command", "prefix", "special"],
  },
  // Fuzzy Search section
  {
    name: "Apps",
    category: "launcher",
    categoryName: "Launcher",
    section: "Fuzzy Search",
    keywords: ["fuzzy", "search", "applications"],
  },
  {
    name: "Actions",
    category: "launcher",
    categoryName: "Launcher",
    section: "Fuzzy Search",
    keywords: ["fuzzy", "search", "actions"],
  },
  {
    name: "Schemes",
    category: "launcher",
    categoryName: "Launcher",
    section: "Fuzzy Search",
    keywords: ["fuzzy", "search", "color schemes"],
  },
  {
    name: "Variants",
    category: "launcher",
    categoryName: "Launcher",
    section: "Fuzzy Search",
    keywords: ["fuzzy", "search", "variants"],
  },
  {
    name: "Wallpapers",
    category: "launcher",
    categoryName: "Launcher",
    section: "Fuzzy Search",
    keywords: ["fuzzy", "search", "backgrounds"],
  },
  // Sizes section
  {
    name: "Item width",
    category: "launcher",
    categoryName: "Launcher",
    section: "Sizes",
    keywords: ["size", "app", "width"],
  },
  {
    name: "Item height",
    category: "launcher",
    categoryName: "Launcher",
    section: "Sizes",
    keywords: ["size", "app", "height"],
  },
  {
    name: "Wallpaper width",
    category: "launcher",
    categoryName: "Launcher",
    section: "Sizes",
    keywords: ["size", "wallpaper", "width"],
  },
  {
    name: "Wallpaper height",
    category: "launcher",
    categoryName: "Launcher",
    section: "Sizes",
    keywords: ["size", "wallpaper", "height"],
  },
  // Actions section
  {
    name: "Launcher actions",
    category: "launcher",
    categoryName: "Launcher",
    section: "Actions",
    keywords: ["commands", "shortcuts", "actions"],
  },
];

// Helper function to search with keywords first, then fuzzy fallback
export function searchSettings(query, fuzzyModule) {
  if (!query || query.trim() === "") {
    return [];
  }

  const q = query.toLowerCase().trim();
  const results = [];
  const seen = new Set();

  // 1. Exact keyword match (highest priority)
  for (const setting of settingsIndex) {
    const key = `${setting.category}:${setting.name}`;
    if (seen.has(key)) continue;

    for (const keyword of setting.keywords) {
      if (keyword.toLowerCase() === q) {
        results.push(
          Object.assign({}, setting, {
            matchType: "exact-keyword",
            score: 1.0,
          }),
        );
        seen.add(key);
        break;
      }
    }
  }

  // 2. Partial keyword match
  for (const setting of settingsIndex) {
    const key = `${setting.category}:${setting.name}`;
    if (seen.has(key)) continue;

    for (const keyword of setting.keywords) {
      if (keyword.toLowerCase().includes(q)) {
        results.push(
          Object.assign({}, setting, {
            matchType: "partial-keyword",
            score: 0.8,
          }),
        );
        seen.add(key);
        break;
      }
    }
  }

  // 3. Name contains query
  for (const setting of settingsIndex) {
    const key = `${setting.category}:${setting.name}`;
    if (seen.has(key)) continue;

    if (setting.name.toLowerCase().includes(q)) {
      results.push(
        Object.assign({}, setting, { matchType: "name-contains", score: 0.7 }),
      );
      seen.add(key);
    }
  }

  // 4. Fuzzy match on name (fallback for typos)
  if (fuzzyModule && results.length < 10) {
    const fuzzyTargets = settingsIndex
      .filter((s) => !seen.has(`${s.category}:${s.name}`))
      .map((s) => Object.assign({}, s, { _searchTarget: s.name }));

    if (fuzzyTargets.length > 0) {
      const fuzzyResults = fuzzyModule.go(query, fuzzyTargets, {
        key: "_searchTarget",
        limit: 10 - results.length,
        threshold: 0.3,
      });

      for (const r of fuzzyResults) {
        const setting = r.obj;
        results.push(
          Object.assign({}, setting, {
            matchType: "fuzzy",
            score: r.score * 0.6,
            _searchTarget: undefined,
          }),
        );
      }
    }
  }

  // Sort by score descending
  results.sort((a, b) => b.score - a.score);

  return results;
}
