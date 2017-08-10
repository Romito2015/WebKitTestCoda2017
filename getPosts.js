var postsWrapper = document.querySelector('.post-list')
var posts = postsWrapper.querySelectorAll('.post.type-post.status-publish')

function preparePosts() {
    var finalPosts = []
    for (var i = 0; i < posts.length; i++) {
        var post = posts[i];
        var currentElemnt = post.querySelector('.post-content h2 a')
        var postTitle = currentElemnt.textContent;
        var postURL = currentElemnt.getAttribute('href');
        finalPosts.push({'postTitle' : postTitle, 'postURL' : postURL});
    }
    return finalPosts
}

var postList = preparePosts()
//webkit.messageHandlers.didGetPosts.postMessage(postsList);

function callNative(message)  {
    try {
        webkit.messageHandlers.didGetPosts.postMessage(postList)
    } catch(err) {
        console.log("Error JAVASCRIPT")
    }
}

callNative()

