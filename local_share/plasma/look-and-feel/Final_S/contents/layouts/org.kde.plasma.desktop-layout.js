var plasma = getApiVersion(1);

var layout = {
    "desktops": [
        {
            "applets": [
                {
                    "config": {
                    },
                    "geometry.height": 0,
                    "geometry.width": 0,
                    "geometry.x": 0,
                    "geometry.y": 0,
                    "plugin": "com.github.prayag2.modernclock",
                    "title": "Modern Clock"
                },
                {
                    "config": {
                        "/ConfigDialog": {
                            "DialogHeight": "630",
                            "DialogWidth": "810"
                        }
                    },
                    "geometry.height": 0,
                    "geometry.width": 0,
                    "geometry.x": 0,
                    "geometry.y": 0,
                    "plugin": "Music.Waves",
                    "title": "Music Waves"
                }
            ],
            "config": {
                "/": {
                    "ItemGeometries-1280x720": "Applet-102:368,144,640,160,0;Applet-103:416,320,576,176,0;",
                    "ItemGeometries-1366x768": "Applet-102:416,144,640,160,0;Applet-103:464,336,576,176,0;",
                    "ItemGeometries-1920x1080": "Applet-102:640,176,640,160,0;Applet-103:736,384,576,176,0;",
                    "ItemGeometriesHorizontal": "Applet-102:640,176,640,160,0;Applet-103:736,384,576,176,0;",
                    "formfactor": "0",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                },
                "/General": {
                    "changedPositions": "{}",
                    "lastResolution": "1920x1080",
                    "positions": "{\"1920x1080\":[\"1\",\"17\"]}",
                    "sortMode": "-1"
                },
                "/Wallpaper/org.kde.color/General": {
                    "Color": "0,0,0"
                },
                "/Wallpaper/org.kde.image/General": {
                    "Image": "/home/nguyendinhkhanh/Downloads/cat-in-clouds.png"
                }
            },
            "wallpaperPlugin": "org.kde.image"
        },
        {
            "applets": [
            ],
            "config": {
                "/": {
                    "formfactor": "0",
                    "immutability": "1",
                    "lastScreen": "1",
                    "wallpaperplugin": "org.kde.image"
                },
                "/Wallpaper/org.kde.image/General": {
                    "Image": "/home/nguyendinhkhanh/Downloads/cat-in-clouds.png"
                }
            },
            "wallpaperPlugin": "org.kde.image"
        }
    ],
    "panels": [
        {
            "alignment": "center",
            "applets": [
                {
                    "config": {
                        "/": {
                            "popupHeight": "548",
                            "popupWidth": "717"
                        },
                        "/ConfigDialog": {
                            "DialogHeight": "630",
                            "DialogWidth": "810"
                        },
                        "/General": {
                            "favoritesPortedToKAstats": "true",
                            "icon": "/home/nguyendinhkhanh/Documents/cat-svgrepo-com.svg",
                            "systemFavorites": "suspend\\,hibernate\\,reboot\\,shutdown"
                        }
                    },
                    "plugin": "org.kde.plasma.kickoff"
                },
                {
                    "config": {
                        "/": {
                            "popupHeight": "153",
                            "popupWidth": "561"
                        },
                        "/ConfigDialog": {
                            "DialogHeight": "630",
                            "DialogWidth": "810"
                        },
                        "/General": {
                            "showIcon": "false"
                        }
                    },
                    "plugin": "org.kde.plasma.windowlist"
                },
                {
                    "config": {
                    },
                    "plugin": "org.kde.plasma.pager"
                },
                {
                    "config": {
                    },
                    "plugin": "org.kde.plasma.marginsseparator"
                },
                {
                    "config": {
                        "/ConfigDialog": {
                            "DialogHeight": "630",
                            "DialogWidth": "810"
                        },
                        "/General": {
                            "launchers": "applications:org.kde.dolphin.desktop,applications:com.microsoft.Edge.desktop,applications:kitty.desktop,applications:discord.desktop"
                        }
                    },
                    "plugin": "org.kde.plasma.icontasks"
                },
                {
                    "config": {
                    },
                    "plugin": "org.kde.plasma.panelspacer"
                },
                {
                    "config": {
                        "/": {
                            "popupHeight": "467",
                            "popupWidth": "541"
                        },
                        "/Appearance": {
                            "autoFontAndSize": "false",
                            "customDateFormat": "d MMM",
                            "fontFamily": "SF Compact Display",
                            "fontStyleName": "Regular",
                            "fontWeight": "400",
                            "segmentOrder": "day,date,time",
                            "segmentSeparator": " ",
                            "showDay": "true",
                            "use24hFormat": "2"
                        },
                        "/ConfigDialog": {
                            "DialogHeight": "630",
                            "DialogWidth": "810"
                        }
                    },
                    "plugin": "com.github.N0repi.compactclock"
                },
                {
                    "config": {
                    },
                    "plugin": "org.kde.plasma.panelspacer"
                },
                {
                    "config": {
                    },
                    "plugin": "org.kde.plasma.systemtray"
                },
                {
                    "config": {
                        "/": {
                            "popupHeight": "510",
                            "popupWidth": "380"
                        },
                        "/Appearance": {
                            "animations": "true",
                            "customButtonImage": "/home/nguyendinhkhanh/Downloads/control-centre-svgrepo-com (3).svg",
                            "layout": "1",
                            "showKDEConnect": "false",
                            "showPercentage": "true",
                            "showScreenshot": "true",
                            "showSessionActions": "false",
                            "transparency": "true",
                            "transparencyLevel": "0"
                        },
                        "/ConfigDialog": {
                            "DialogHeight": "630",
                            "DialogWidth": "810"
                        }
                    },
                    "plugin": "KdeControlStation"
                },
                {
                    "config": {
                    },
                    "plugin": "org.kde.plasma.showdesktop"
                }
            ],
            "config": {
                "/": {
                    "formfactor": "2",
                    "immutability": "1",
                    "lastScreen": "0",
                    "wallpaperplugin": "org.kde.image"
                }
            },
            "height": 1.5625,
            "hiding": "normal",
            "lengthMode": "fill",
            "location": "top",
            "maximumLength": 75.875,
            "minimumLength": 75.875,
            "offset": 0,
            "opacity": "translucent"
        }
    ],
    "serializationFormatVersion": "1"
}
;

plasma.loadSerializedLayout(layout);
