// Jenkinsfile: scripted Jenkins pipefile
// This file was automatically generated using 'python -m vsc.install.ci'
// DO NOT EDIT MANUALLY

pipeline {
agent any
stages {
    stage('checkout git') {
        steps {
            checkout scm
            // remove untracked files (*.pyc for example)
            sh 'git clean -fxd'
        }
    }
    stage('install uv') {
        steps {
            sh 'curl -L --silent https://github.com/astral-sh/uv/releases/latest/download/uv-x86_64-unknown-linux-gnu.tar.gz --output - | tar -xzv'
            sh 'cp uv-x86_64-unknown-linux-gnu/uv .'
            sh './uv --version'
            sh './uv python install 3.9'
            sh './uv sync --python 3.9 --managed-python'
            sh './uv sync --python 3.9 --managed-python --group dev'
        }
    }
    stage('test pipeline') {
        parallel {
            stage('test') {
                steps {
                    sh './uv run tox'
                    sh 'rm -r $PWD/.venv $PWD/.tox'
                }
            }
        }
    }
}}
