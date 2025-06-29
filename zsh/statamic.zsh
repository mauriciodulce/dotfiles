alias p="php please"
alias pdeets="php please support:details"
alias puserme="cp ~/.dotfiles/statamic/mauricio@dulce.dev.yaml users/mauricio@dulce.dev.yaml"
alias stacheid="a tinker --execute=\"echo app('stache')->generateId()\" | pbcopy"


# ------------------------------------------------------------------------------
# Setup a fresh Statamic site, ready for development.
# ------------------------------------------------------------------------------

pfresh() {
    cd ~/Code/Support
    statamic new $1 --no-interaction
    cd $1
    puser
    osslink statamic/cms
    init

    echo ""
    echo "Site created at ~/Code/Statamic/$1"
    echo "Site: http://$1.test"
    echo "Control Panel: http://$1.test/cp"
}


# ------------------------------------------------------------------------------
# Install an existing Statamic site & setup all the things.
# ------------------------------------------------------------------------------

pinstall() {
    if [ -f ./.env ]; then
        echo "Site already has a .env file. Continuing..."
    elif [ -f ./.env.example ]; then
        cp .env.example .env
    else
        echo "No .env.example file found. Copying from ~/.dotfiles/statamic/.env.example"
        cp ~/.dotfiles/statamic/.env.example ./.env
    fi

    ci
    a key:generate

    if [ -f ./package.json ]; then
        echo "Running npm install..."
        npm install

        if grep -q "build" package.json; then
            echo "Running npm run build..."
            npm run build
        elif grep -q "prod" package.json; then
            echo "Running npm run prod..."
            npm run prod
        elif grep -q "production" package.json; then
            echo "Running npm run production..."
            npm run production
        fi
    fi

    puser
    p pro:enable
    osslink statamic/cms
}
