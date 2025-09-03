FROM node:18-slim

RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    default-jre \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /home/cc/EnvGym/data/iamkun_dayjs

RUN git clone https://github.com/iamkun/dayjs.git .

RUN npm install

RUN echo '{\n\
  "root": true,\n\
  "extends": ["airbnb-base"],\n\
  "plugins": ["import", "jest"],\n\
  "env": {\n\
    "jest": true,\n\
    "node": true,\n\
    "browser": true\n\
  },\n\
  "rules": {\n\
    "semi": ["error", "never"],\n\
    "comma-dangle": ["error", "never"],\n\
    "no-param-reassign": "off",\n\
    "no-nested-ternary": "off",\n\
    "no-extend-native": "off",\n\
    "no-plusplus": "off",\n\
    "no-return-assign": "off",\n\
    "import/no-extraneous-dependencies": ["error", {"devDependencies": true}]\n\
  }\n\
}' > .eslintrc.js

RUN echo '{\n\
  "singleQuote": true,\n\
  "semi": false,\n\
  "trailingComma": "none",\n\
  "arrowParens": "avoid"\n\
}' > .prettierrc

RUN echo 'node_modules/\n\
dist/\n\
coverage/\n\
.env\n\
.DS_Store\n\
esm/\n\
*.log\n\
.idea/\n\
.vscode/\n\
*.swp\n\
*.swo\n\
*~' > .gitignore

RUN echo 'registry=https://registry.npmjs.org/\n\
save-exact=true' > .npmrc

RUN echo 'root = true\n\
\n\
[*]\n\
indent_style = space\n\
indent_size = 2\n\
end_of_line = lf\n\
charset = utf-8\n\
trim_trailing_whitespace = true\n\
insert_final_newline = true\n\
\n\
[*.md]\n\
trim_trailing_whitespace = false' > .editorconfig

RUN mkdir -p .github/workflows && \
    echo 'name: CI\n\
\n\
on:\n\
  push:\n\
    branches: [ master, development ]\n\
  pull_request:\n\
    branches: [ master ]\n\
\n\
jobs:\n\
  test:\n\
    runs-on: ubuntu-latest\n\
    strategy:\n\
      matrix:\n\
        node-version: [14.x, 16.x, 18.x]\n\
    steps:\n\
    - uses: actions/checkout@v3\n\
    - name: Use Node.js ${{ matrix.node-version }}\n\
      uses: actions/setup-node@v3\n\
      with:\n\
        node-version: ${{ matrix.node-version }}\n\
    - run: npm ci\n\
    - run: npm run lint\n\
    - run: npm run build\n\
    - run: npm test\n\
    - run: npm run size' > .github/workflows/ci.yml

RUN echo '{\n\
  "presets": [\n\
    ["@babel/preset-env", {\n\
      "modules": false,\n\
      "loose": true\n\
    }]\n\
  ],\n\
  "env": {\n\
    "test": {\n\
      "presets": [\n\
        ["@babel/preset-env", {\n\
          "targets": {\n\
            "node": "current"\n\
          }\n\
        }]\n\
      ]\n\
    }\n\
  }\n\
}' > babel.config.js

RUN echo 'import babel from "@rollup/plugin-babel";\n\
import { terser } from "rollup-plugin-terser";\n\
\n\
const config = {\n\
  input: "src/index.js",\n\
  output: [\n\
    {\n\
      file: "dayjs.min.js",\n\
      format: "umd",\n\
      name: "dayjs"\n\
    }\n\
  ],\n\
  plugins: [\n\
    babel({\n\
      exclude: "node_modules/**",\n\
      babelHelpers: "bundled"\n\
    }),\n\
    terser()\n\
  ]\n\
};\n\
\n\
export default config;' > rollup.config.js

RUN echo 'module.exports = function(config) {\n\
  config.set({\n\
    frameworks: ["jasmine"],\n\
    files: [\n\
      "dayjs.min.js",\n\
      "test/**/*.js"\n\
    ],\n\
    preprocessors: {\n\
      "test/**/*.js": ["babel"]\n\
    },\n\
    browsers: ["ChromeHeadless"],\n\
    singleRun: true,\n\
    reporters: ["progress", "coverage"],\n\
    coverageReporter: {\n\
      type: "lcov",\n\
      dir: "coverage/"\n\
    }\n\
  });\n\
};' > karma.conf.js

RUN echo '[\n\
  {\n\
    "path": "dayjs.min.js",\n\
    "limit": "2.99 KB"\n\
  }\n\
]' > .size-limit.json

RUN npm run prettier || true
RUN npm run lint || true
RUN npm run babel || true
RUN npm run build || true

RUN git config --global user.email "test@example.com" && \
    git config --global user.name "Test User" && \
    git add . && \
    git commit -m "Initial setup" || true && \
    git checkout -b development || true

ENV TZ=UTC
ENV NODE_ENV=development

CMD ["/bin/bash"]