/* eslint-env node */
const path = require('path');
module.exports = () => {
   if (process.env.NODE_ENV === 'production') {
       return require(path.resolve(__dirname,"webpack/webpack.prod.js"))
   }
   else{
       return require(path.resolve(__dirname,"webpack/webpack.dev.js"))
   }
}