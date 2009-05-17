## Qt Lib name.
qt_webkit_name = QtWebkit

## Libraries linked to the cpp part (is active only when  CPP_SHARED == true).
webkit_link_cpp += qtdcore_cpp $(qt_core_lib_name) $(qt_gui_lib_name) $(qt_network_lib_name)

## Libraries linked to the d part (is active only when  CPP_SHARED == true)..
webkit_link_d += qtdcore

## Module specific cpp files.
webkit_cpp_files += 

## Module specific d files.
webkit_d_files += 

## Classes.
## TODO: use list that generated by dgen.
webkit_classes = \
    ArrayOps \
    QWebFrame \
    QWebHistoryInterface \
    QWebHistoryItem \
    QWebHistory \
    QWebHitTestResult \
    QWebPage \
    QWebSettings \
    QWebView