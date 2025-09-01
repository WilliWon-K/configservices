<#macro registrationLayout displayInfo=false displayMessage=true displayWide=false displayBranding=true displayPassword=true displayRecaptcha=false bodyClass="" showAnotherWayIfPresent=true displayRequiredFields=false>
<!DOCTYPE html>
<html lang="${msg("locale")}">
<head>
    <meta charset="utf-8">
    <title>${msg("loginTitle",(realm.displayName!''))}</title>
    <link rel="stylesheet" href="${url.resourcesPath}/css/styles.css">
</head>
<body class="${bodyClass}">
    <div id="kc-container" class="${properties.kcContainerClass!}">
        <div id="kc-container-wrapper">
            <div id="kc-content">
                <div id="kc-content-wrapper">
                    <#nested "form">
                </div>
            </div>
        </div>
    </div>
</body>
</html>
</#macro>
