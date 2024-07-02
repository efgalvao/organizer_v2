// esbuild.config.js

const sassPlugin = require('esbuild-plugin-sass');
const { readFile } = require('fs/promises');

const isProduction = process.env.NODE_ENV === 'production';

module.exports = {
  entryPoints: ['app/javascript/application.js'],
  bundle: true,
  minify: isProduction,
  sourcemap: !isProduction,
  outdir: 'public/assets/builds',
  publicPath: '/assets',
  plugins: [
    sassPlugin({
      async resolve({ path }) {
        if (path.endsWith('.scss')) {
          return { loader: 'scss', contents: await readFile(path, 'utf8') };
        }
      },
    }),
  ],
};
