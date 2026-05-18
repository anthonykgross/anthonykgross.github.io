module.exports = {
  purge: ["**/*.{html,md,js}"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      screens: {
        print: { raw: 'print' },
        screen: { raw: 'screen' },
      },
      fontSize: {
        'xxs': '.5rem',
      },
      colors: {
        akgWhite: {
          DEFAULT: '#FFF'
        },
        akgBlack: {
          DEFAULT: '#212529',
        },
        akgFontGrey: {
          DEFAULT: '#A9B7C6'
        },
        akgBlue: {
          DEFAULT: '#3A9ADB',
          dark: '#355771'
        },
      },
      fontFamily: {
        'open-sans': ['Open Sans'],
        'jenna-sue': ['JennaSue'],
      }
    }
  },
  variants: {
    extend: {
      margin: ['last'],
    },
  },
  plugins: [],
}
