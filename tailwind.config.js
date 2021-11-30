module.exports = {
  purge: ["**/*.{html,md,js}"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      fontSize: {
        'xxs': '.5rem',
      },
      colors: {
        akgBgWhite: {
          DEFAULT: '#F6F6F6'
        },
        akgFontBlack: {
          DEFAULT: '#232525'
        },
        akgFontGrey: {
          DEFAULT: '#A9B7C6'
        },
        akgBlue: {
          DEFAULT: '#598DBB',
          dark: '#355771'
        }
      },
      fontFamily: {
        'fjalla': ['Fjalla One'],
      }
    }
  },
  variants: {
    extend: {},
  },
  plugins: [],
}
