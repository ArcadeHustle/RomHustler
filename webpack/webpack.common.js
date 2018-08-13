const path = require('path');
const { VueLoaderPlugin } = require('vue-loader');
const commonConfig = {
  entry: path.resolve(__dirname, '../src/index.js'),
  output: {
      filename: 'bundle.js',
      path: path.resolve(__dirname, '../static/ui'),
      publicPath: './webpack/'
  },
  plugins: [
      // make sure to include the plugin!
      new VueLoaderPlugin()
  ],
  resolve: {
      alias: {
          'vue$': 'vue/dist/vue.esm.js'
      }
  },
  module: {
    rules: [
      {
          test: /\.pug$/,
          oneOf: [
              // this applies to <template lang="pug"> in Vue components
              {
                  resourceQuery: /^\?vue/,
                  use: ['pug-plain-loader']
              },
              // this applies to pug imports inside JavaScript
              {
                  use: ['raw-loader', 'pug-plain-loader']
              }
          ]
      },
      {
          test: /\.vue$/,
          loader: 'vue-loader'
      },
      {
        test: /\.css$/,
        use: ["style-loader", "css-loader"]
      },
      {
          test: /\.(png|jpe?g|gif|svg|woff|woff2|ttf|eot|ico)(\?.*)?$/,
          use: {
              loader: 'url-loader',
              options: {
                  limit: 10000
              }
          }
      },
      {
        test: /\.scss$/,
        use: ["style-loader", "css-loader", "sass-loader"]
      }
    ]
  }
};
module.exports = commonConfig;