name: Ejecutar automatización de PR en ambiente develop
run-name: ${{ github.actor }} is testing out GitHub Actions 🚀
# Definition when the workflow should run
on:
    # The workflow will run whenever an event happens on a pull request
    pull_request:
      types: [closed]
      branches: [ develop ]
      paths:
        - 'force-app/**'

jobs:
  Explore-GitHub-Actions:
    runs-on: ubuntu-latest
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
  
  InicioDespliegue:
    runs-on: ubuntu-latest
    needs: [Explore-GitHub-Actions]
    env:
      Secreto: ${{ secrets.SERVERKEY}}
      CLIENT_ID: ${{ secrets.CLIENT_ID }}
      INSTANCE_URL:  ${{ vars.URL }}
      SF_USERNAME:  ${{ vars.SF_USERNAME }}    
    steps:
      # Checkout the Source code from the latest commit
      - name: Checkout code
        uses: actions/checkout@v4
        with:
           fetch-depth: 0
           
      - name: Set up Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '22.11.0'
          
      - name: Install the SF CLI
        run: |
          npm install @salesforce/cli --global
          sf --help 

      - name: Install sfdx-git-delta
        run: echo 'y' | sfdx plugins:install sfdx-git-delta

      - name: Create delta directory
        run: mkdir ./delta_source

      - name: Check changes
        run: sfdx sgd:source:delta --to HEAD --from HEAD~1 -o ./delta_source -d -s force-app/

      - name: Show package.xml
        run: cat ./delta_source/package/package.xml

      - name: create folder
        run: 
          mkdir -p ./key

      - name: Authenticate with Salesforce CLI using JWT flow
        run: |
           echo "${Secreto}" > ./key/server.key
           sf org login jwt --username  ${{ env.SF_USERNAME }} --jwt-key-file "./key/server.key" --client-id ${{ env.CLIENT_ID }} --instance-url ${{ env.INSTANCE_URL }}  --alias develop --set-default  --json 
      
      - name: Verify Authentication
        run: |
          sf org list
          
      - name:  Validación de Codigo 
        run:
         sf project deploy validate --manifest "./delta_source/package/package.xml" --test-level RunLocalTests --target-org develop
 
      - name: Deploy Salesforce
        run: 
          sf project deploy start --manifest "./delta_source/package/package.xml"  --target-org develop --ignore-conflicts 

      - name: Install the SFDX CLI Scanner
        run: |
          echo 'y' | sf plugins install @salesforce/sfdx-scanner
      
      - name: Create reports directory
        run: mkdir -p reports

      - name: Run SFDX CLI Scanner 
        run: |
          sf scanner run -f html -t "./force-app" -e "eslint,retire-js,pmd,cpd" -c "Design,Best Practices,Code Style,Performance,Security" --outfile reports/scan-reports.html 
     
      - uses: actions/upload-artifact@v4
        with:
            name: cli-scan-report
            path: reports/scan-reports.html