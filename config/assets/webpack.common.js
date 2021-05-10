//
const path = require("path");
const webpack = require("webpack");

const MiniCssExtractPlugin = require("mini-css-extract-plugin");
const WebpackAssetsManifest = require("webpack-assets-manifest");
const { CleanWebpackPlugin } = require("clean-webpack-plugin");

const root = path.resolve(__dirname, "../../");

module.exports = function (env, argv) {
  return {
    entry: {
      application: ["main.js", "main.sass"],
      manifest: "manifest.js",
    },

    context: path.resolve("app/assets"),

    output: {
      path: path.join(root, "public/assets"),
      filename: "[name].[contenthash].js",
      publicPath: env.publicPath,
    },

    resolve: {
      modules: [path.join(root, "app/assets"), path.join(root, "node_modules")],
      alias: {
        bourbon: "bourbon/app/assets/stylesheets",
      },
      extensions: [
        ".coffee",
        ".js",
        ".sass",
        ".scss",
        ".css",
        ".png",
        ".svg",
        ".jpg",
      ],
    },

    module: {
      rules: [
        {
          test: /\.(ico|eot|ttf|woff|woff2|jpe?g|png|gif|svg)$/i,
          use: [
            {
              loader: "file-loader",
              options: {
                name: env.dev
                  ? "[path][name].[ext]"
                  : "[name].[contenthash].[ext]",
              },
            },
          ],
        },
        {
          test: /\.(scss|sass|css)$/i,
          use: [
            {
              loader: MiniCssExtractPlugin.loader,
              options: {
                // CSS bundles must be compiled into the output top directory
                // otherwise url(...) links will be wrong!
                publicPath: "",
                esModule: true,
              },
            },
            {
              loader: "css-loader",
              options: {
                esModule: true,
                importLoaders: 2,
                sourceMap: true,
              },
            },
            {
              loader: "postcss-loader",
              options: {
                sourceMap: true,
                postcssOptions: {
                  plugins: [
                    require("postcss-preset-env")(),
                    require("cssnano")(),
                  ],
                },
              },
            },
            {
              loader: "sass-loader",
              options: {
                sourceMap: true,
              },
            },
          ],
        },
        {
          test: /\.(jsx?|coffee)$/i,
          use: [
            {
              loader: "babel-loader",
              options: {
                presets: [
                  [
                    "@babel/preset-env",
                    {
                      modules: false,
                      loose: true,
                    },
                  ],
                ],
                plugins: [
                  ["@babel/plugin-transform-react-jsx", { pragma: "h" }],
                ],
              },
            },
          ],
        },
        {
          test: /\.coffee$/i,
          use: ["coffee-loader"],
          enforce: "pre",
        },
        {
          test: /\.(png|svg|jpg|gif)$/i,
          loader: "image-webpack-loader",
          enforce: "pre",
        },
      ],
    },

    plugins: [
      new CleanWebpackPlugin(),
      new MiniCssExtractPlugin({
        filename: "[name].[contenthash].css",
      }),
      new WebpackAssetsManifest({
        contextRelativeKeys: true,
        integrity: true,
        integrityHashes: ["sha384"],
        output: "manifest.json",
        publicPath: env.publicPath,
        writeToDisk: true,
        customize(entry, original, manifest, asset) {
          if (entry.key.match(/(^manifest\.js$|\.gz$|\.map$|\.txt$|^\.)/)) {
            // Skip files not needed in the asset manifest.
            //
            // The `manifest.js` entrypoint only defines external assets such as
            // images and shall not be used otherwise.
            return false;
          }
        },
      }),
      new webpack.optimize.ModuleConcatenationPlugin(),
    ],
  };
};
