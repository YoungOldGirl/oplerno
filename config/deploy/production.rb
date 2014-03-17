set :stage, :production

set :branch, 'develop'
set :deploy_to, '/home/deploy/www'

role :app, %w{deploy@app01 deploy@app02 deploy@db01}
role :web, %w{deploy@web01 deploy@web02}
role :db, %w{deploy@db01}

set :ssh_options, {
    keys: %w(~/.ssh/id_rsa),
    forward_agent: true,
    auth_methods: %w(publickey),
}
