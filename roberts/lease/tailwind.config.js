const colors = require('tailwindcss/colors')

module.exports = {
  purge: ['./pages/**/*.{js,ts,jsx,tsx}', './components/**/*.{js,ts,jsx,tsx}'],
  darkMode: false, // or 'media' or 'class'
  theme: {
     extend: {
       fontFamily: {
        Meow: ["Meow Script", "cursive"],
        Lily: ['Lily Script One', "cursive"],
       },
       colors: {
        transparent: 'transparent',
        current: 'currentColor',
        midnight: '#121063',
        metal: '#565584',
        'tahiti': {
  100: '#cffafe',
  200: '#a5f3fc',
  300: '#67e8f9',
  400: '#22d3ee',
  500: '#06b6d4',
  600: '#0891b2',
  700: '#0e7490',
  800: '#155e75',
  900: '#164e63',
},
        silver: '#ecebff',
        'bubble-gum': '#ff77e9',
        bermuda: '#78dcca',
        stone: '#292524',
        stonelight: '#44403c',
        sky:'#e0f2fe',
        teal: "#99f6e4",
        cyan: "#155e75",
        teallight:"#f0fdfa",
        tealdark:"#0c4a6e"
      },
     },
   },

  variants: {
    extend: {},
  },
  plugins: [],
}
