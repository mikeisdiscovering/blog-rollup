# blog
**blog** is a blockchain built using Cosmos SDK and Tendermint and created with [Ignite CLI](https://ignite.com/cli). It is a rollup edition power by celestia.

## Run it locally

1. start your local celestia devnet node.

```
docker run -p 26650:26657 -p 26659:26659 ghcr.io/rollkit/local-celestia-devnet:v0.9.1
```

2. Check the local node working status by Query your balance

Open a new terminal instance. Check the balance on your account that you'll be using to post blocks to the local network, this will make sure you can post rollup blocks to your Celestia Devnet for DA & consensus:

`curl -X GET http://0.0.0.0:26659/balance`

You will see something like this, denoting your balance in TIA x 10-6:

{"denom":"utia","amount":"999995000000000"}

that means it is working.
3. install golang and ignite-cli
golang
```
curl https://dl.google.com/go/go1.19.2.linux-amd64.tar.gz | sudo tar -C/usr/local -zxvf - ;
cat <<'EOF' >>$HOME/.bashrc
export GOROOT=/usr/local/go
export GOPATH=$HOME/go
export GO111MODULE=on
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.bashrc
```
ignite Here we are using `ignite v0.25.1`
```
git clone https://github.com/ignite/cli.git
cd cli && git checkout v0.25.1
make install
```
check your installation by running `ignite version`

4. install jq
```
sudo apt-get install jq -y
```
5. Start your local blog node.

`bash init-local.sh`

## Run it on testnet
You must run a testnet light node first.
And you testnet wallet must have enough balance to pay the fee.
if you are running lightnode on local machine.
```
bash init-testnet.sh
```
if you are running light node on remote machine ,you must open the gateway.
```
bash init-testnet.sh http://YourLightnodeIP:26659
```


## Test the functionality of the blog app.
We can test the blog app after it is running.

### Keys
List your keys:

`blogd keys list --keyring-backend test`


You should see an output like the following

```
- address: blog1pzjq0s34fvyxm7357mmsqllhvmc3vp4lx5463v
  name: blog-key-2
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"A38qouzSGmfRoJjisjtCdNXp25kbKEg8sno8D1Oz1uJc"}'
  type: local
- address: blog1n7he8ngtxtqpa9zmcd9fvfydts9veca4xa0ee0
  name: blog-key
  pubkey: '{"@type":"/cosmos.crypto.secp256k1.PubKey","key":"AkSU5RQ6rys+gOc+nqFcUJ27X7iVStw4nGuxCwugZZBL"}'
  type: local
```

### Send token
Now we can test sending a transaction from one of our keys to the other. We can do that with the following command:

`blogd tx bank send [from_key_or_address] [to_address] [amount] [flags]`

Set your keys as variables to make it easier to add the address:

```
export KEY1=blog1n7he8ngtxtqpa9zmcd9fvfydts9veca4xa0ee0
export KEY2=blog1pzjq0s34fvyxm7357mmsqllhvmc3vp4lx5463v
```
So using our information from the keys command, we can construct the transaction command like so to send 999999stake from one address to another:

`blogd tx bank send $KEY1 $KEY2 999999stake --keyring-backend test -y`



### Balances
Then, query your balance:

`blogd query bank balances $KEY2`

This is the key that received the balance, so it should have increased past the initial STAKING_AMOUNT:
```
balances:
- amount: "10000000000000000000999999"
  denom: stake
  pagination:
  next_key: null
  total: "0"
```
The other key, should have decreased in balance:

`blogd query bank balances $KEY1`

Response:
```
balances:
- amount: "9999999999999998999000001"
  denom: stake
  pagination:
  next_key: null
  total: "0"
```
### Create a post

`blogd tx blog create-post 'Hello, World!' 'This is a blog post' --from blog-key --keyring-backend test -y`

### Query the post
After creating a post, we can query the post
`blogd q blog list-post`

This is the result:
```
Post:
- body: This is a blog post
  creator: blog1n7he8ngtxtqpa9zmcd9fvfydts9veca4xa0ee0
  id: "0"
  title: Hello, World!
  pagination:
  next_key: null
  total: "0"
```
### Update the post
`blogd tx blog update-post 0 'Hello, World!' 'This is a blog post from blog-key' --from  blog-key --keyring-backend test -y`

After updating the post, we can query the post
`blogd q blog list-post`
The result is:
```
Post:
- body: This is a blog post from blog-key
  creator: blog1n7he8ngtxtqpa9zmcd9fvfydts9veca4xa0ee0
  id: "0"
  title: Hello, World!
pagination:
  next_key: null
  total: "0"
```

### Delete the post
Only the  author of the post can delete the post. Here we try to use another account to delete the post.
`blogd tx blog delete-post 0 --from blog-key-2 --keyring-backend test`

We can get the txhash after sending transactions. and query it. such as:
`blogd query tx 89FE4D24B050BD862B89D559DB07DD74290CBF2B26885EB406BB94A35BC5EA91`
```
code: 4
codespace: sdk
data: ""
events:
- attributes:
  - index: true
    key: ZmVl
    value: null
  - index: true
    key: ZmVlX3BheWVy
    value: YmxvZzFwempxMHMzNGZ2eXhtNzM1N21tc3FsbGh2bWMzdnA0bHg1NDYzdg==
  type: tx
- attributes:
  - index: true
    key: YWNjX3NlcQ==
    value: YmxvZzFwempxMHMzNGZ2eXhtNzM1N21tc3FsbGh2bWMzdnA0bHg1NDYzdi8w
  type: tx
- attributes:
  - index: true
    key: c2lnbmF0dXJl
    value: NkdMOW04bEQ1VkJjQ0w1YkpvK0VzTFN4d1E3a1NlOU14VUlJRkFwckxHeE5TNjZEVVp4MFpVV1MzV3JXVjV2dTZxVVI1YTRQeVYwZTR1SFgzUURtU1E9PQ==
  type: tx
gas_used: "54551"
gas_wanted: "200000"
height: "25"
info: ""
logs: []
raw_log: 'failed to execute message; message index: 0: incorrect owner: unauthorized'
timestamp: "2023-05-05T12:48:22Z"
tx:
  '@type': /cosmos.tx.v1beta1.Tx
  auth_info:
    fee:
      amount: []
      gas_limit: "200000"
      granter: ""
      payer: ""
    signer_infos:
    - mode_info:
        single:
          mode: SIGN_MODE_DIRECT
      public_key:
        '@type': /cosmos.crypto.secp256k1.PubKey
        key: A38qouzSGmfRoJjisjtCdNXp25kbKEg8sno8D1Oz1uJc
      sequence: "0"
    tip: null
  body:
    extension_options: []
    memo: ""
    messages:
    - '@type': /blog.blog.MsgDeletePost
      creator: blog1pzjq0s34fvyxm7357mmsqllhvmc3vp4lx5463v
      id: "0"
    non_critical_extension_options: []
    timeout_height: "0"
  signatures:
  - 6GL9m8lD5VBcCL5bJo+EsLSxwQ7kSe9MxUIIFAprLGxNS66DUZx0ZUWS3WrWV5vu6qUR5a4PyV0e4uHX3QDmSQ==
txhash: 89FE4D24B050BD862B89D559DB07DD74290CBF2B26885EB406BB94A35BC5EA91
```

We can see the raw_log: `failed to execute message; message index: 0: incorrect owner: unauthorized`

And we can query the post again:

`blogd q blog list-post`

The result is still same as before.
```
Post:
- body: This is a blog post from blog-key
  creator: blog1n7he8ngtxtqpa9zmcd9fvfydts9veca4xa0ee0
  id: "0"
  title: Hello, World!
  pagination:
  next_key: null
  total: "0"
```

We can use the author account to delete the post.
`blogd tx blog delete-post 0 --from blog-key --keyring-backend test -y`

Then we can query the post again:
`blogd q blog list-post`
The result should be 
```
Post: []
pagination:
  next_key: null
  total: "0"
```

The post has been deleted successfully.
