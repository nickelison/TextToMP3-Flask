var clipboard = new ClipboardJS('#clipButton')

clipboard.on('success', function(e) {
    var exampleEl = document.getElementById('clipButton')
    var tooltip = new bootstrap.Tooltip(exampleEl)
    tooltip.hide()
    exampleEl.setAttribute('data-original-title', 'Copied!')
    tooltip.show();
    setTimeout(function() {
        tooltip.hide();
    }, 1000);
    e.clearSelection();
});

clipboard.on('error', function(e) {
    var exampleEl = document.getElementById('clipButton')
    var tooltip = new bootstrap.Tooltip(exampleEl)
    tooltip.hide()
    exampleEl.setAttribute('data-original-title', 'Ctrl + C to copy')
    tooltip.show();
    setTimeout(function() {
        tooltip.hide();
    }, 1000);
});


function showUserMenu() {
    var userMenuElm = document.getElementById('nav-user-menu');

    if (userMenuElm.style.display == 'flex') {
       userMenuElm.style.display = 'none';
    } else {
        userMenuElm.style.display = 'flex';
    }
}

function showSiteMenu() {
    var siteMenuElm = document.getElementById('nav-site-menu');

    if (siteMenuElm.style.display == 'flex') {
       siteMenuElm.style.display = 'none';
    } else {
        siteMenuElm.style.display = 'flex';
    }
}

window.addEventListener('mouseup', function(e) {
    var userMenuElm = document.getElementById('nav-user-menu');
    var siteMenuElm = document.getElementById('nav-site-menu');

    if (userMenuElm) {
        if (!userMenuElm.contains(e.target)) {
            if (e.target.id !== 'nav-avatar-image') {
                userMenuElm.style.display = 'none';
            }

        }
    }

    if (siteMenuElm) {
        if (!siteMenuElm.contains(e.target)) {
            if (e.target.id !== 'nav-site-menu-link') {
                siteMenuElm.style.display = 'none';
            }
        }
    }
})


function showCdaModal() {
    fetch('/delete-account/', {
        method: 'POST',
        headers: {
            'Accept': 'application/json, text/plain, */*',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(
            {
                data: null
            }
        )
    }).then(function(res) {
        return res.text();
    }).then(function(data) {
        // remove old modal if exists
        if (document.getElementById('cdaDiv')) {
            document.getElementById('cdaDiv').remove();
        }

        // create new modal element
        var vfm = document.createElement('div');
        vfm.id = 'cdaDiv';
        vfm.innerHTML = data;
        document.getElementsByTagName('main')[0].appendChild(vfm);

        // create new modal object
        var modal = new bootstrap.Modal(document.getElementById('cdaModal'), {});
        modal.show();

        // close modal onclick
        document.getElementById('cdaModalClose').onclick = function(e) {
            e.preventDefault();
            modal.hide();
            document.getElementById('cdaDiv').remove();
        }
    })
}

function showResetApiKeyModal() {
    fetch('/reset-api-key', {
        method: 'POST',
        headers: {
            'Accept': 'application/json, text/plain, */*',
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(
            {
                data: null
            }
        )
    }).then(function(res) {
        return res.text();
    }).then(function(data) {
    // remove old modal if exists
        if (document.getElementById('rakDiv')) {
            document.getElementById('rakDiv').remove();
        }

        // create new modal element
        var vfm = document.createElement('div');
        vfm.id = 'rakDiv';
        vfm.innerHTML = data;
        document.getElementsByTagName('main')[0].appendChild(vfm);

        // create new modal object
        var modal = new bootstrap.Modal(document.getElementById('rakModal'), {});
        modal.show();

        // close modal onclick
        document.getElementById('rakModalClose').onclick = function(e) {
            e.preventDefault();
            modal.hide();
            document.getElementById('rakDiv').remove();
        }
    })
}
