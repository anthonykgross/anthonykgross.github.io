module.exports = {
  purge: ["**/*.{html,md,js}"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      fontSize: {
        'xxs': '.5rem',
      },
      colors: {
        akgBgWhite: '#F6F6F6',
        akgFontBlack: '#232525',
        akgFontGrey: '#A9B7C6',
        akgBlue: '#598DBB'
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
