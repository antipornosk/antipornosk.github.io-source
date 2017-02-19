# [antiporno.sk](http://www.antiporno.sk/) sources

This site was built with [hakyll](https://jaspervdj.be/hakyll).

Before fist run, you need to compile it with
```
stack build
```

To test the site run
```
stack exec site rebuild
```
It will be on `http://localhost:8000`

If you just change the templates nothing else is needed.

If you change `site.sh`, you need to run `stack build` again.

To deploy the site run `./deploy.sh`. Don't forget to commit and push source code afterwards.