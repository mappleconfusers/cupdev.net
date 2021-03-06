_  = require 'underscore'
_s = require 'underscore.string'

#
# Pseudo Y Combinator
# Mutates a function so that it's first argument will be itself.
# Useful for anonymous recusion
Y = (f) ->
  (a...) ->
    f (Y f), a...

#
# Map, but expects a nested list.
# Each sublist will be passed to the
# function as parameters.
#
# TODO: Merge with underscore?
# TODO: Might be better as function modifier 'apply'
mapply = (argvv, f) ->
  _.map argvv,(args) ->
    f args...

#
# Replacement for mapply as a modifier
# Takes a function and modifies it so,
# that it takes an array for it's list of arguments.
# TODO: underscore?
vecarg = (f) ->
  (a) ->
    f a...

# 
# The opposite of vecarg:
# Takes a function and modifies it so,
# that it recievs it's arguments as an
# array
# TODO: underscore?
variad = (f) ->
  (a...) ->
    f a

#
# Join multiple dicts (objects).
# The returned value is a completely new array.
#
# TODO: Merge with underscore?
joinD = (a...) ->
  _.extend {}, _.flatten a

# Map on a dictionary.
# Takes a dict and a function 'f(key, value, store)'
# where store is the target dict
# returns oneother dict.
# Each invocation of 'f' must return a dict itself.
# TODO: Merge with underscore?
mapD = (dic, f) ->
  joinD \
    mapply (_.pairs dic), f

# Filter a Dictionary.
# TODO: Merge with underscore?
filterD = (dic,f) ->
  joinD filter (_.pairs dic), vecarg f

#
# Filter a dictionary,
# but include the pair
# if the test evaluates false.
# TODO: underscore?
rejectD = (dic,f) ->
  filterD dic, (a...) -> !f a...

#
# Wrapper to get the length of something
len = (o) -> o.length

# Takes an array of indices and
# one array of values and creates
# a third array which contains at pos n
# the value for values[indices[n]
#
# $ att [3,2,4,2,1], ['aa', 'b', 'c', 'd', 'e', null, null]
# => ['d', 'c','e','c','b']
att = (idxv, valv) ->
  _.map idxv, (i) ->
    valv[i]

# Takes an (flat) array and
# creates a nested array with n
# elements in each chunk
chunkify = (a, n=2) ->
  _.map (_.range 0, (len a), n), (beg) ->
    att (_.range beg, beg+n), a

# Takes key-value pairs and turns them into a dict
fromPairs = (pairs) ->
  r={}
  _.each pairs, vecarg (k,v) ->
    r[k]=v
  r

# Same as fromPairs but takes a 'stream' rather than a set of pairs
# (Dic key1, value1, key2, …) rather than fromPairs [[key1, value1], [key2, value2], …]
Dic = (a...) ->
  fromPairs (chunkify a)

P = (a...) ->
  console.log a...
  a[0]

rev = (ar) ->
  _.times ar.length, (i) ->
    ar[ar.length - 1 - i]

#
# Contcats all given args to an array
conc = (a...) ->
  [].concat a

castarray = (x) ->
  if _.isArray x
    x
  else
    r = _.toArray x
    if r
      r
    else
      [x]

tree_mknode = (tree, path__, newn=(->{})) ->
  wp = tokenize path__, '/'
  sp = _.tail wp
  node = _.head wp
  
  if node && !tree[node]
    tree[node] = newn()

  if _.isEmpty wp
    return tree

  tree_mknode tree[node], sp, newn

tree_set = (tree,path__,value) ->
  path = tokenize path__, '/'

  dir = tree_mknode tree, (_.initial path)
  dir[_.last path] = value

tokenize = (l,sep=null) ->
  if _.isArray l
    a = l
  else if _.isString l
    return wordlist l, sep
  else
    a = castarray l

  _.map a, (x) -> _s.strip x


# 
# Take a node from the ContentTree
# and check it it is a file
treefile = (n) ->
  n && n.__filename

#
# Traverse dict by path:
# Takes a path as array or unix-format
# and returns the element in a tree
#
# If the element does not exist exist
# the function will just return null or
# undefined without throwing an error.
#
# TODO: exists method
# TODO: Include lib?
traverse = (d,p) ->
  if _.isString p # TODO: TOKENIZE?
    p = _.map (_s.words p, "/"), (s) -> _s.strip s

  if p.length < 1
    return d

  if d
    traverse d[_.head p], _.tail p
  
embed = (x, root) ->
  x= castarray x         # Handle non-array args x -> [x]
  x= _.map x, (e) ->     # Extract all files
    if _.isString e        # Handle string args
      e = traverse root, e
    if treefile e          # Handle Files
      return [e]
    _.values e             # Handle dirs
  x= _.flatten x, true   # Vectorize
  x= _.reject x, (e) ->  # Reject meta contents
    _.contains (tokenize e.metadata.flags), "meta"
  x= _.sortBy x, (art) -># Sort by date
    art.date
  x= _.uniq x, true      # Remove duplicates
  x= rev x

flatfiles = (x,root) ->
  x= castarray x         # Handle non-array args x -> [x]
  x= _.map x, (e) ->     # Extract all files
    if _.isString e        # Handle string args
      e = traverse root, e
    if treefile e          # Handle Files
      return [e]
    _.values e             # Handle dirs
  x= _.flatten x, true   # Vectorize

wordlist = (x,sep=',') ->
  x= _s.words x, sep
  x= _.map x, (x) -> _s.strip x
  x= _.filter x, (s) -> s

treesec = (x) ->
  x= _s.words x, /\//
  x= _.map x, (x) -> _s.strip x
  x= _.filter x, (s)->s
  x= _.times x.length, (i) ->
    name: x[i]
    path: _s.join "/", x[..i]
    depth: i

module.exports =
  _:  _
  _s: _s
  P:  P
  rev: rev
  embed:    embed
  wordlist: wordlist
  treesec:  treesec
  flatfiles: flatfiles
  tokenize: tokenize
  tree_set: tree_set
  tree_mknode: tree_mknode
  mapply: mapply
  joinD: joinD
  mapD: mapD
  filterD: filterD
  traverse: traverse
  Y: Y
  len: len
  att: att
  chunkify: chunkify
  Dic: Dic
  fromPairs: fromPairs
  conc: conc
