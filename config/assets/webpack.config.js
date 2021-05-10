//

module.exports = function (env = {}, argv) {
  if (
    argv.mode === undefined &&
    (process.env.NODE_ENV === "production" ||
      process.env.RAILS_ENV === "production")
  ) {
    argv.mode = "production";
  }

  if (env.dev === undefined) {
    env.dev = argv.mode !== "production";
  }

  if (env.publicPath === undefined) {
    env.publicPath = "/assets/";
  }

  if (env.dev) {
    return require("./webpack.dev.js")(env, argv);
  } else {
    return require("./webpack.prod.js")(env, argv);
  }
};
