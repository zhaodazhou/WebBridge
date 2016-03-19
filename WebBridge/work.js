function NativeCallWeb(info){
    
    alert('call testNativeCallWeb')
    return 'success NativeCallWeb'
}

function NativeCallWebBywdobject(info){
    wdobject.webCallNative(info);
    alert(info)
    return info
}