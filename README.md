atwite
==========
_the reproachable content tracker_


 atwite is a simple content tracker that changes a folder with code in it to a Dropbox-synchronized repo.
 It uses YAML to create a _point file_ that looks like this
 
<pre>
--- 
title: title

description: |
  A description

commits: 
- "2012-07-03 23:48:27 user : new commit"

tags: 
- tag1
- tag2
</pre>

that makes the point of the repo state. Collaborators and sharing options can be set up from Dropbox.

Usage
------

```
    init :  initialize new repo
    add :   add files to the indexing list
    push :  copy the files on the indexing list to Dropbox repo
    commit: add a commit to the point file
    flush:  delete local repo files
    remove: delete local repo files and Dropbox folder
    clone:  copy a repo from Dropbox to local folder
```

Status
------

needs work/testing/fixing
