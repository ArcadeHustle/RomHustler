const webpackMerge = require('webpack-merge');
const commonConfig = require('./webpack.common.js');
const devConfig = {
    mode: 'development',
    module: {
        rules: [
            {
                test: /\.scss$/,
                use: [
                    {
                        loader: "style-loader"
                    },
                    {
                        loader: "css-loader", options: { sourceMap: true }
                    },
                    {
                      loader: "sass-loader", options: { sourceMap: true }
                    }
                ]
            },
            {
                enforce: 'pre',
                test: /\.(js|vue)$/,
                loader: 'eslint-loader',
                exclude: /node_modules/
            }
        ]
    }
}
module.exports = webpackMerge(commonConfig, devConfig);