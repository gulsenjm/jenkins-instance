def k8slabel = "jenkins-pipeline-${UUID.randomUUID().toString()}"
def slavePodTemplate = """ 
      metadata:
        labels:
          k8s-label: ${k8slabel}
        annotations:
          jenkinsjoblabel: ${env.JOB_NAME}-${env.BUILD_NUMBER}
      spec:
        affinity:
          podAntiAffinity:
            requiredDuringSchedulingIgnoredDuringExecution:
            - labelSelector:
                matchExpressions:
                - key: component
                  operator: In
                  values:
                  - jenkins-jenkins-master
              topologyKey: "kubernetes.io/hostname" 
        containers:                                            
        - name: buildtools                        
          image: fuchicorp/buildtools
          imagePullPolicy: IfNotPresent
          command:
          - cat
          tty: true
          volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
        - name: docker
          image: docker:latest
          imagePullPolicy: IfNotPresent
          command:
          - cat
          tty: true
          volumeMounts:
            - mountPath: /var/run/docker.sock
              name: docker-sock
        serviceAccountName: default
        securityContext:
          runAsUser: 0
          fsGroup: 0
        volumes:
          - name: docker-sock
            hostPath:
              path: /var/run/docker.sock
    """

    properties([
        parameters([              
            booleanParam(defaultValue: false, description: 'Please select to apply the changes ', name: 'terraformApply'),             
            booleanParam(defaultValue: false, description: 'Please select to destroy all ', name: 'terraformDestroy'),                 
            choice(choices: ['us-west-2', 'us-west-1', 'us-east-2', 'us-east-1', 'eu-west-1'], description: 'Please select the region', name: 'aws_region'),
            choice(choices: ['TRACE', ' DEBUG', ' INFO', ' WARN', ' ERROR'], description: 'Please select a log', name: 'terraform_logs'), 
            choice(choices: ['dev', 'qa ', 'stage', 'prod'], description: 'Please select the environment to deploy', name: 'environment'),
            string(defaultValue: 'None', description: 'Please provide an image ID', name: 'ami_id', trim: false),
            string(defaultValue: 'None', description: 'Please provide a Name', name: 'Name', trim: false)
        ])
    ])
    
    podTemplate(name: k8slabel, label: k8slabel, yaml: slavePodTemplate, showRawYaml: false) {    
      node(k8slabel) {
        stage("Pull SCM") { 
            git 'https://github.com/gulsenjm/jenkins-instance/'
            
        }

        stage("Generate Variables") {                
          dir('deployments/terraform') {
            println("Generate Variables")
            def deployment_configuration_tfvars = """   
            println("1")
            environment = "${environment}" 
            println("2")
            ami= "${ami_id}"
            println("3")
            Name= "${Name}"
            println("4")
            """.stripIndent()   
            println("5")                   
            writeFile file: 'deployment_configuration.tfvars', text: "${deployment_configuration_tfvars}"  
            println("6")
            sh 'cat deployment_configuration.tfvars >> dev.tfvars'         
            println("successfull")
          }   
        }
        
        container("buildtools") {               
            dir('deployments/terraform') {      
               withCredentials([usernamePassword(credentialsId: "aws-access-${environment}",   
                  passwordVariable: 'AWS_SECRET_ACCESS_KEY', usernameVariable: 'AWS_ACCESS_KEY_ID')]) {    
                  println("Selected cred is: aws-access-${environment}")
                    stage("Terraform Apply/plan") {
                        if (!params.terraformDestroy) {     
                            if (params.terraformApply) {        
                                println("Applying the changes")
                                sh """
                                #!/bin/bash
                                export AWS_DEFAULT_REGION=${params.aws_region}    
                                source ./setenv.sh dev.tfvars   //creating backend.tf based on your configuration
                                TF_LOG=${params.terraform_logs} terraform apply -auto-approve -var-file \$DATAFILE
                                """                         
                            } 
                              else {
                                  println("Planing the changes")
                                  sh """
                                  #!/bin/bash
                                  set +ex     // means whatever command you are running show me in console 
                                  ls -l
                                  export AWS_DEFAULT_REGION=${aws_region}
                                  source ./setenv.sh dev.tfvars
                                  TF_LOG=${params.terraform_logs} terraform plan -var-file \$DATAFILE
                                  """
                              }
                        }
                    }

                    stage("Terraform Destroy") {                                
                        if (params.terraformDestroy) {
                            println("Destroying the all")
                            sh """
                            #!/bin/bash
                            export AWS_DEFAULT_REGION=${params.aws_region}
                            source ./setenv.sh dev.tfvars                               
                            TF_LOG=${params.terraform_logs} terraform destroy -auto-approve -var-file \$DATAFILE  //TF_LOG added here 
                            """
                        }
                          else {
                              println("Skiping the destroy")
                          }
                    }
                }

            }
        }
      }
    }