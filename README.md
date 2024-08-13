# Welcome to Cardano Developer Studio
This repository is the home of the Cardano Developer Studio, an all-in-one suite designed to streamline the development process for Cardano blockchain developers. Our goal is to provide an accessible, comprehensive set of tools and resources to support developers in building dApps and smart contracts efficiently on the Cardano platform.

## Table of Contents
- [Welcome to Cardano Developer Studio](#welcome-to-cardano-developer-studio)
   - [Table of Contents](#table-of-contents)
   - [Documentation](#documentation)
   - [Features](#features)
   - [What is included](./docs/README_INCLUDED.md#what-is-included)
      - [Cardano Node](./docs/README_INCLUDED.md#cardano-node)
      - [Cardano Wallet](./docs/README_INCLUDED.md#cardano-wallet)
      - [Cardano DB Sync](./docs/README_INCLUDED.md#cardano-db-sync)
      - [Helpers Library](./docs/README_INCLUDED.md#helpers-library)
      - [Examples Suite](./docs/README_INCLUDED.md#example-suite)
      - [Testing Suite](./docs/README_INCLUDED.md#testing-suite)
      - [Script Menus and Tools](./docs/README_INCLUDED.md#script-menus-and-tools)
      - [Dockerized Tools Ready for Use](./docs/README_INCLUDED.md#dockerized-tools-ready-for-use)
   - [Why Developers Need to Experiment with These Tools](./docs/README_INCLUDED.md#why-developers-need-to-experiment-with-these-tools)
   - [Installation and Setup](./docs/README_INSTALLATION.md)
      - [Why Choose the DevContainer Method?](./docs/README_INSTALLATION.md#why-choose-the-devcontainer-method)
      - [Updating Bash and Installing Package Managers](./docs/README_INSTALLATION.md#updating-bash-and-installing-package-managers)
         - [In Windows](./docs/README_INSTALLATION.md#in-windows)
         - [In Mac](./docs/README_INSTALLATION.md#in-mac)
         - [In Ubuntu (and other Linux Distributions)](./docs/README_INSTALLATION.md#in-ubuntu-and-other-linux-distributions)
   - [Note on Package Managers](./docs/README_INSTALLATION.md#note-on-package-managers)
   - [Running Bash Scripts](./docs/README_INSTALLATION.md#running-bash-scripts)
      - [On Windows](./docs/README_INSTALLATION.md#on-windows)
      - [On Mac](./docs/README_INSTALLATION.md#on-mac)
   - [Docker Containers](./docs/README_DOCKER.md)
      - [What is Docker?](./docs/README_DOCKER.md#what-is-docker)
      - [Why Docker for Our Scripts?](./docs/README_DOCKER.md#why-docker-for-our-scripts)
      - [Getting Started with Docker](./docs/README_DOCKER.md#getting-started-with-docker)
      - [Note to Users](./docs/README_DOCKER.md#note-to-users)
   - [Using the Dev Container in VS Code](./docs/README_VSCODE.md)
      - [Introduction](./docs/README_VSCODE.md#introduction)
      - [Prerequisites](./docs/README_VSCODE.md#prerequisites)
      - [Open Your Project in VS Code](./docs/README_VSCODE.md#open-your-project-in-vs-code)
      - [Start the Development Container](./docs/README_VSCODE.md#start-the-development-container)
      - [Work Inside the Container](./docs/README_VSCODE.md#work-inside-the-container)
      - [Stop the Development Container](./docs/README_VSCODE.md#stop-the-development-container)
      - [Next Steps](./docs/README_VSCODE.md#next-steps)
   - [Initial Requirements Checks by the Script](./docs/README_VSCODE.md#initial-requirements-checks-by-the-script)
      - [What the Script Checks](./docs/README_VSCODE.md#what-the-script-checks)
   - [Running the Main Script](./docs/README_SCRIPT.md)
      - [How to Use `run.sh`](./docs/README_SCRIPT.md#how-to-use-runsh)
      - [Main Menu](./docs/README_SCRIPT.md#main-menu)
      - [Docker Compose Menu](./docs/README_SCRIPT.md#docker-compose-menu)
      - [Cardano Node Tools Menu](./docs/README_SCRIPT.md#cardano-node-tools-menu)
      - [Cardano Wallet Tools Menu](./docs/README_SCRIPT.md#cardano-wallet-tools-menu)
      - [Cardano DB Sync Tools Menu](./docs/README_SCRIPT.md#cardano-db-sync-tools-menu)
      - [Cardano Development Tools Menu](./docs/README_SCRIPT.md#cardano-development-tools-menu)
         - [Validators Contract Examples CLI](./docs/README_SCRIPT.md#validators-contract-examples-cli)
         - [Policies Contract Examples CLI](./docs/README_SCRIPT.md#policies-contract-examples-cli)
      - [Note to Users](./docs/README_SCRIPT.md#note-to-users-1)
   - [Using the Docker Containers](./docs/README_CONTAINERS.md)
      - [Cardano Node](./docs/README_CONTAINERS.md#cardano-node)
      - [Cardano Wallet](./docs/README_CONTAINERS.md#cardano-wallet)
         - [Importing API Collections into Postman](./docs/README_CONTAINERS.md#importing-api-collections-into-postman)
      - [Cardano DB Sync](./docs/README_CONTAINERS.md#cardano-db-sync) 
      - [Plutus Development Tools](./docs/README_CONTAINERS.md#plutus-development-toolkit)
   - [Plutus Smart Contracts Examples and Helpers Library](./examples/README.md)
      - [Helpers Library](./examples/README.md#helpers-library)
         - [Step-by-Step Guide: Using the Helpers Library](./examples/README.md#step-by-step-guide-using-the-helpers-library)
      - [Testing Functions](./examples/README.md#testing-functions)
      - [Examples Directory](./examples/README.md#examples-directory)
         - [Examples](./examples/README.md#examples)
            - [Policy AlwaysFalse](./examples/README.md#policy-alwaysfalse)
            - [Policy AlwaysTrue](./examples/README.md#policy-alwaystrue)
            - [Policy CheckDate](./examples/README.md#policy-checkdate)
            - [Policy CheckSignature](./examples/README.md#policy-checksignature)
            - [Policy RedeemerFT](./examples/README.md#policy-redeemerft)
            - [Policy RedeemerNFT](./examples/README.md#policy-redeemernft)
            - [Validator AlwaysFalse](./examples/README.md#validator-alwaysfalse)
            - [Validator AlwaysTrue](./examples/README.md#validator-alwaystrue)
            - [Validator CheckDate](./examples/README.md#validator-checkdate)
            - [Validator CheckSignature](./examples/README.md#validator-checksignature)
         - [Choosing your Environment](./examples/README.md#choosing-your-environment)
            - [Docker Compose](./examples/README.md#docker-compose)
            - [Dev Container](./examples/README.md#dev-container)
            - [Local Execution](./examples/README.md#local-execution)
            - [Set Up Local Environment for Compiling Cabal Projects](./examples/README.md#set-up-local-environment-for-compiling-cabal-projects)
         - [Step-by-Step Guide: Running the Example CLI](./examples/README.md#step-by-step-guide-running-the-example-cli)
            - [Step-by-Step Guide to build and test the examples](./examples/README.md#step-by-step-guide-to-build-and-test-the-examples)
            - [Step-by-Step Guide to deploy the compiled Plutus smart contracts](./examples/README.md#step-by-step-guide-to-deploy-the-compiled-plutus-smart-contracts)
            - [Step-by-Step Guide to make transactions with the examples](./examples/README.md#step-by-step-guide-to-make-transactions-with-the-examples)
         - [Using a Terminal](./examples/README.md#using-a-terminal)
   - [Contribution](#contribution)
   - [License](#license)
   - [Acknowledgements](#acknowledgements)
   - [Ongoing Progress](#ongoing-progress)

## Documentation
**Gitbook**

https://protofire-docs.gitbook.io/developer-studio/

## Features

- Docker Compose Configurations: Simplify setup and integration of all necessary tools.
- Script Tool with Menus: Navigate, configure, and run various tools through an intuitive menu system.
- Pre-built Smart Contract Examples: Access a suite of example contracts that demonstrate various functionalities in Plutus, helping you get started quickly.
- Comprehensive Testing Tools: Utilize testing tools for resource consumption, transaction size analysis, and contract evaluation to ensure compliance with Plutus constraints.
- Dockerized Tools Ready for Use: All tools are dockerized, ensuring a consistent and streamlined development environment across different setups.

## Contribution

Contributions to the Cardano Developer Studio are welcome. Whether you're looking to fix bugs, add new features, or improve documentation, your help is appreciated. Please see our contribution guidelines for more information.

## License

This project is licensed under the GNU General Public License v3.0 - see the [LICENSE](LICENSE) file for details.

## Acknowledgements

We express our deepest gratitude to the Cardano community for their unwavering support and valuable contributions to this project. This work is part of a funded project through Cardano Catalyst, a community-driven innovation platform. For more details on the proposal and its progress, please visit our proposal page on [IdeaScale](https://cardano.ideascale.com/c/idea/110047).

## Ongoing Progress

Welcome to the beginning of a journey! You're looking at the first milestone and release of our Cardano Developer Studio, where the foundations are set, but the building is far from over. As we continue to grow and evolve, expect to see an array of new menus, tools, and functionalities rolled out in future updates. Each release will be packed with features designed to make the Cardano development experience smoother, more intuitive, and increasingly powerful. Stay tuned, and grow with us, as we expand the possibilities and support you, the builders of tomorrow's Cardano ecosystem. Your feedback, ideas, and contributions will shape the road ahead, so let's forge this path together!
