const webpackMerge = require('webpack-merge');
const commonConfig = require('./webpack.common.js');
const UglifyJsPlugin = require('uglifyjs-webpack-plugin');
const prodConfig = {
    mode: 'production',
    optimization: {
        minimizer: [new UglifyJsPlugin({ sourceMap: false })]
    },
    module: {
        rules: [
            {
                test: /\.scss$/,
                use: [
                    { loader: "style-loader" },
                    { loader: "css-loader", options: { sourceMap: false } },
                    { loader: "sass-loader", options: { sourceMap: false } }
                ]
            }
        ]
    }
}
module.exports = webpackMerge(commonConfig, prodConfig);