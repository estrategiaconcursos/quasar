#!/bin/sh

echo "Removendo diretorios antigos..."
rm -rf app cli docs fastclick ui babel-preset-app

BRANCH="quasar-v$VERSION"
echo "Clonando quasar tag $BRANCH em $QUASAR..."
rm -rf $QUASAR 2>/dev/null
git clone --depth 1 --branch $BRANCH https://github.com/quasarframework/quasar.git $QUASAR

echo "Copiando diretorios base do quasar..."
mv $QUASAR/app $QUASAR/cli $QUASAR/docs $QUASAR/fastclick $QUASAR/ui $QUASAR/babel-preset-app .

cat > cli/assets/logo.art <<\EOF
oooooooooooo              .                          .                         o8o           
`888'     `8            .o8                        .o8                         `"'           
 888          .oooo.o .o888oo oooo d8b  .oooo.   .o888oo  .ooooo.   .oooooooo oooo   .oooo.  
 888oooo8    d88(  "8   888   `888""8P `P  )88b    888   d88' `88b 888' `88b  `888  `P  )88b 
 888    "    `"Y88b.    888    888      .oP"888    888   888ooo888 888   888   888   .oP"888 
 888       o o.  )88b   888 .  888     d8(  888    888 . 888    .o `88bod8P'   888  d8(  888 
o888ooooood8 8""888P'   "888" d888b    `Y888""8o   "888" `Y8bod8P' `8oooooo.  o888o `Y888""8o
                                                                   d"     YD                 
                                                                    "Y88888P'                 
                                                                                             
EOF

echo "Substituindo URL de download do starter kit..."
sed -i 's,quasarframework/quasar-starter-kit,direct:REPO_URL/starter-kit.tar.gz,g' cli/bin/quasar-create

echo "Atualizando starter kit..."
rm -rf /tmp/old-starter-kit 2>/dev/null
mv starter-kit /tmp/old-starter-kit
git clone --depth 1 https://github.com/quasarframework/quasar-starter-kit starter-kit
rm -rf starter-kit/.git*
rm -rf starter-kit/template
mv /tmp/old-starter-kit/template starter-kit/

cat > starter-kit/meta.js <<\EOF
const { complete } = require('./utils')
const escape = val => JSON.stringify(val).slice(1, -1)

module.exports = {
  prompts: {
    name: {
      type: 'string',
      message: 'Project name (internal usage for dev)',
      validate: val => val && val.length > 0
    },

    productName: {
      type: 'string',
      message: 'Project product name (must start with letter if building mobile apps)',
      default: 'Quasar App',
      validate: val => val && val.length > 0,
      transformer: escape
    },

    description: {
      type: 'string',
      message: 'Project description',
      default: 'A Quasar Framework app',
      transformer: escape
    },

    author: {
      type: 'string',
      message: 'Author'
    },

    css: {
      type: 'list',
      message: 'Pick your favorite CSS preprocessor: (can be changed later)',
      default: 'stylus',
      choices: [
        {
          name: 'Stylus',
          value: 'stylus'
        },
        {
          name: 'None (the others will still be available)',
          value: 'none',
          short: 'None'
        }
      ]
    },

    importStrategy: {
      type: 'list',
      message: 'Pick a Quasar components & directives import strategy: (can be changed later)',
      choices: [
        {
          name: '* Import everything from Quasar\n    - not treeshaking Quasar; biggest bundle size',
          value: 'all',
          short: 'Import everything',
          checked: true
        }
      ]
    },

    preset: {
      type: 'checkbox',
      message: 'Check the features needed for your project:',
      choices: [
        {
          name: 'ESLint (recommended)',
          value: 'lint',
          checked: true
        },
        {
          name: 'Vuex',
          value: 'vuex'
        }
      ]
    },

    typescriptConfig: {
      when: 'preset.typescript',
      type: 'list',
      message: 'Pick a component style:',
      choices: [
        {
          name:
            'Composition API (recommended) (https://github.com/vuejs/composition-api)',
          value: 'composition',
          short: 'Composition',
        },
        {
          name:
            'Class-based (recommended) (https://github.com/vuejs/vue-class-component & https://github.com/kaorun343/vue-property-decorator)',
          value: 'class',
          short: 'Class',
        },
        {
          name: 'Options API',
          value: 'options',
          short: 'options',
        }
      ]
    },

    lintConfig: {
      when: 'preset.lint',
      type: 'list',
      message: 'Pick an ESLint preset:',
      choices: [
        {
          name: 'Standard (https://github.com/standard/standard)',
          value: 'standard',
          short: 'Standard',
        }
      ]
    },

    autoInstall: {
      type: 'list',
      message:
        'Continue to install project dependencies after the project has been created? (recommended)',
      choices: [
        {
          name: 'Yes, use NPM',
          value: 'npm',
          short: 'NPM',
        },
        {
          name: 'No, I will handle that myself',
          value: false,
          short: 'no',
        }
      ]
    }
  },

  filters: {
    // ESlint files
    '.eslintignore': 'preset.lint',
    '.eslintrc.js': 'preset.lint',

    // Default files when not using TypeScript
    'jsconfig.json': '!preset.typescript',
    'src/router/*.js': '!preset.typescript',

    // Presets files when not using TypeScript
    'src/boot/axios.js': 'preset.axios && !preset.typescript',
    'src/boot/i18n.js': 'preset.i18n && !preset.typescript',
    'src/i18n/**/*.js': 'preset.i18n && !preset.typescript',
    'src/store/**/*.js': 'preset.vuex && !preset.typescript',

    // TypeScript files
    '.prettierrc': `preset.lint && preset.typescript && lintConfig === 'prettier'`,
    'tsconfig.json': 'preset.typescript',
    'src/env.d.ts': 'preset.typescript',
    'src/shims-vue.d.ts': 'preset.typescript',
    'src/components/CompositionComponent.vue': `preset.typescript && typescriptConfig === 'composition'`,
    'src/components/ClassComponent.vue': `preset.typescript && typescriptConfig === 'class'`,
    'src/components/OptionsComponent.vue': `preset.typescript && typescriptConfig === 'options'`,
    'src/components/models.ts': `preset.typescript`,

    // Default files using TypeScript
    'src/router/*.ts': 'preset.typescript',

    // Presets files using TypeScript
    'src/boot/axios.ts': 'preset.axios && preset.typescript',
    'src/boot/composition-api.ts': `preset.typescript && typescriptConfig === 'composition'`,
    'src/boot/i18n.ts': 'preset.i18n && preset.typescript',
    'src/i18n/**/*.ts': 'preset.i18n && preset.typescript',
    'src/store/**/*.ts': 'preset.vuex && preset.typescript',

    // CSS preprocessors
    '.stylintrc': `preset.lint && css === 'stylus'`,
    'src/css/*.styl': `css === 'stylus'`,
    'src/css/*.scss': `css === 'scss'`,
    'src/css/*.sass': `css === 'sass'`,
    'src/css/app.css': `css === 'none'`,
  },

  complete
};
EOF
echo "Fim."
