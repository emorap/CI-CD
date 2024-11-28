# Salesforce DX Project: Next Steps

Now that you’ve created a Salesforce DX project, what’s next? Here are some documentation resources to get you started.

## How Do You Plan to Deploy Your Changes?

Do you want to deploy a set of changes, or create a self-contained application? Choose a [development model](https://developer.salesforce.com/tools/vscode/en/user-guide/development-models).

## Configure Your Salesforce DX Project

The `sfdx-project.json` file contains useful configuration information for your project. See [Salesforce DX Project Configuration](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_ws_config.htm) in the _Salesforce DX Developer Guide_ for details about this file.

## Read All About It

- [Salesforce Extensions Documentation](https://developer.salesforce.com/tools/vscode/)
- [Salesforce CLI Setup Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_setup.meta/sfdx_setup/sfdx_setup_intro.htm)
- [Salesforce DX Developer Guide](https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_intro.htm)
- [Salesforce CLI Command Reference](https://developer.salesforce.com/docs/atlas.en-us.sfdx_cli_reference.meta/sfdx_cli_reference/cli_reference.htm)

## Para implementsar CICD seguir estos manuales
https://developer.salesforce.com/docs/atlas.en-us.sfdx_dev.meta/sfdx_dev/sfdx_dev_auth_key_and_cert.htm
https://medium.com/@danielbelini/how-to-install-salesforce-cli-on-github-actions-91287138abba
https://www.apexhours.com/ci-cd-pipeline-using-gitlab-for-salesforce/
https://github.com/salto-io/salesforce-ci-cd-org-dev/blob/master/.github/workflows/pr-develop-branch.yml

https://github.com/amitastreait/github-actions/?tab=readme-ov-file#integrate-the-static-code-analysis-tool


sfdx force:auth:jwt:grant --clientid 3MVG9AR068fT4uszYXeLVVMxnyfzZe.8EheVp1RuN3rbtENZXCmcF_x8xeikX640ak.UivTCzD_f0ddCtZNZA --jwtkeyfile /Users/edgar.mora/Downloads/server.key --username edgar.mora@clarosfi.com.co.devops --instanceurl https://clarosfi--devops.sandbox.my.salesforce.com –setdefaultdevhubusername --json

sf org login jwt --username  edgar.mora@clarosfi.com.co.devops --jwt-key-file /Users/edgar.mora/Downloads/server.key --client-id 3MVG9AR068fT4uszYXeLVVMxnyfzZe._x8xeikX640ak.UivTCzD_f0ddCtZNZA --instance-url https://clarosfi--devops.sandbox.my.salesforce.com --json

- name: Authenticate with Salesforce CLI using JWT flow part 2
        run: 
          sfdx auth:jwt:grant --clientid ${{ env.CLIENT_ID }} -f Certifications/server.key -u -a jwt-login --instanceurl ${{ env.INSTANCE_URL }}


      - name: Validate deployment
        run: |
            echo "Running deployment validation"
            echo "Running deployment validation" ${{env.APEX_TESTS}}

            sf project deploy validate --source-dir "./delta_source/force-app" --wait 1000 --verbose --test-level RunSpecifiedTests --tests ${{env.APEX_TESTS}} --target-org jwt-login

            sf project deploy start --manifest packageChanges.xml --target-org  $(username-qa) --test-level RunLocalTests --dry-run --ignore-conflicts


steps:
      - run: echo "🎉 The job was automatically triggered by a ${{ github.event_name }} event."
      - run: echo "🐧 This job is now running on a ${{ runner.os }} server hosted by GitHub!"
      - run: echo "🔎 The name of your branch is ${{ github.ref }} and your repository is ${{ github.repository }}."
      - name: Check out repository code
        uses: actions/checkout@v3

      - run: echo "💡 The ${{ github.repository }} repository has been cloned to the runner."
      - run: echo "🖥️ The workflow is now ready to test your code on the runner."
      - name: List files in the repository
        run: |
          ls ${{ github.workspace }}
      - run: echo "🍏 This job's status is ${{ job.status }}."



## Prueba de JWT-Based Flow
sf org login jwt --username  edgar@clarosfi.com.co.devops --jwt-key-file /Users/edgar.mora/Downloads/server.key --client-id {ADD_YOUR_CLIENT_ID} --instance-url https://test.salesforce.com --json

–clientid  :- provide Consumer Key
–jwtkeyfile :- Absolute path to the location where you generated your OpenSSL server.key file
–instanceurl :-provide instanceurl if you are using sandbox.