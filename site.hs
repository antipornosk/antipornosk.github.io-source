--------------------------------------------------------------------------------
{-# LANGUAGE OverloadedStrings #-}
import           Data.Monoid (mappend)
import           Hakyll
import           System.FilePath (takeBaseName, replaceExtension, takeFileName)
import           Data.Functor

--------------------------------------------------------------------------------
main :: IO ()
main = hakyllWith config $ do
    match "images/*" $ do
        route   idRoute
        compile copyFileCompiler

    match "lib/**" $ do
        route   idRoute
        compile copyFileCompiler

    match "css/*" $ do
        route   idRoute
        compile compressCssCompiler

    match (fromList ["oprojekte.markdown", "kontakt.markdown", "odkazy.markdown"]) $ do
        route   $ setExtension "html"
        compile $ pandocCompiler
            >>= loadAndApplyTemplate "templates/default.html" siteCtx
            >>= relativizeUrls

    match "posts/*" $ do
        route $ setExtension "html"
        compile $ pandocCompiler
            >>= saveSnapshot "postSnapshot"
            >>= loadAndApplyTemplate "templates/post.html"    postCtx
            >>= loadAndApplyTemplate "templates/default.html" postCtx
            >>= relativizeUrls
{-
    create ["archive.html"] $ do
        route idRoute
        compile $ do
            posts <- recentFirst =<< loadAll ("posts/*" .&&. hasNoVersion)
            rawPosts <- recentFirst =<< loadAll ("posts/*" .&&. hasVersion "raw")
            let archiveCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    listField "rawPosts" postCtx (return rawPosts) `mappend`
                    constField "title" "Archives"            `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/archive.html" archiveCtx
                >>= loadAndApplyTemplate "templates/default.html" archiveCtx
                >>= loadAndApplyTemplate "templates/right-panel.html" archiveCtx
                >>= relativizeUrls
-}


    match "posts/*" $ version "raw" $ do
        compile getResourceBody

    create ["right-panel.html"] $ do
        compile $ do
            rawPosts <- recentFirst =<< loadAll ("posts/*" .&&. hasVersion "raw")
            let rightPanelCtx =
                    listField "rawPosts" rawPostCtx (return rawPosts) `mappend`
                    defaultContext

            makeItem ""
                >>= loadAndApplyTemplate "templates/right-panel.html" rightPanelCtx
                >>= relativizeUrls

    match "index.html" $ do
        route idRoute
        compile $ do
            posts <- fmap (map dropPreview) .fmap (take 10) . recentFirst =<< loadAllSnapshots ("posts/*" .&&. hasNoVersion) "postSnapshot"
            -- posts <- recentFirst =<< loadAll "posts/*"
            rawPosts <- recentFirst =<< loadAll ("posts/*" .&&. hasVersion "raw")
            let indexCtx =
                    listField "posts" postCtx (return posts) `mappend`
                    listField "rawPosts" rawPostCtx (return rawPosts) `mappend`
                    constField "title" "Home"                `mappend`
                    mainCtx

            getResourceBody
                >>= applyAsTemplate indexCtx
                >>= loadAndApplyTemplate "templates/default.html" indexCtx
                >>= relativizeUrls

    match "templates/*" $ compile templateCompiler

dropPreview :: Item String -> Item String
dropPreview = fmap (unlines . takeWhile (/= "<!-- PREVIEW -->") . drop 1 . dropWhile (/= "<!-- PREVIEW -->") . lines)
              where preview = (/=) "<!-- PREVIEW -->"

config :: Configuration
config = defaultConfiguration
    { deployCommand = "./deploy.sh"
    }

--------------------------------------------------------------------------------
activeClassField :: Context a
activeClassField = functionField "activeMenuClass" $ \[p] _ -> do
    path <- toFilePath <$> getUnderlying
    return $ if takeBaseName path == takeBaseName p then "active" else "inactive"

mainCtx :: Context String
mainCtx = activeClassField `mappend` defaultContext


siteCtx :: Context String
siteCtx =
    listField "rawPosts" rawPostCtx (loadAll $ "posts/*" .&&. hasVersion "raw") `mappend`
    mainCtx

postCtx :: Context String
postCtx =
    dateField "date" "%e.%m.%Y" `mappend`
    listField "posts" defaultContext (loadAll $ "posts/*" .&&. hasNoVersion) `mappend`
    listField "rawPosts" rawPostCtx ((loadAll $ "posts/*" .&&. hasVersion "raw") >>= recentFirst) `mappend`
    mainCtx



rawPostCtx :: Context String
rawPostCtx =
    dateField "date" "%e.%m.%Y" `mappend`
    (field "url" $ return . (\p -> "/" ++ replaceExtension p "html") . toFilePath . itemIdentifier) `mappend`
    defaultContext
