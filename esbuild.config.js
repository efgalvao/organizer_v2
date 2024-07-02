const esbuild = require('esbuild');
const sassPlugin = require('esbuild-plugin-sass');

esbuild.build({
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  sourcemap: true,
  outdir: 'app/assets/builds',
  publicPath: '/assets',
  plugins: [sassPlugin()],
  loader: {
    '.js': 'jsx',
    '.scss': 'css',
  },
}).catch(() => process.exit(1));
