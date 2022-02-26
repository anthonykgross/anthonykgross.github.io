module.exports = {
  purge: ["**/*.{html,md,js}"],
  darkMode: false, // or 'media' or 'class'
  theme: {
    extend: {
      fontSize: {
        'xxs': '.5rem',
      },
      colors: {
        akgWhite: {
          DEFAULT: '#FFF'
        },
        akgBlack: {
          DEFAULT: '#212529',
          dark: '#060607',
        },
        akgFontGrey: {
          DEFAULT: '#A9B7C6'
        },
        akgBlue: {
          DEFAULT: '#3A9ADB',
          dark: '#355771'
        },
        akgRed: {
          DEFAULT: '#FE6061'
        },
        social: {
          twitter: '#00aced',
          facebook: '#4267B2',
        }
      },
      fontFamily: {
        'open-sans': ['Open Sans'],
        'jenna-sue': ['JennaSue'],
      }
    }
  },
  variants: {
    extend: {
      margin: ['last']
    },
  },
  plugins: [],
}
