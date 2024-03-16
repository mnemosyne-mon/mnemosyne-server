//
const { merge } = require("webpack-merge");

module.exports = function (env, argv) {
  let common = require("./webpack.common.js")(env);

  return merge(common, {
    mode: "development",
    devtool: "inline-source-map",

    stats: {
      errorDetails: true,
    },

    output: {
      pathinfo: true,
    },

    devServer: {
      static: {
        directory: "/public/",
        serveIndex: true,
        watch: {
          ignored: /node_modules/,
        },
      },
      host: "0.0.0.0",
      port: 3001,
      proxy: [{ context: "/", target: "http://localhost:3000" }],
    },
  });
};
