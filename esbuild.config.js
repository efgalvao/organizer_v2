const esbuild = require('esbuild');
const sassPlugin = require('esbuild-plugin-sass');

esbuild.build({
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  sourcemap: true,
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  minify: true,
  plugins: [sassPlugin()],
  watch: true, // Ensure this is enabled
}).catch(() => process.exit(1));
