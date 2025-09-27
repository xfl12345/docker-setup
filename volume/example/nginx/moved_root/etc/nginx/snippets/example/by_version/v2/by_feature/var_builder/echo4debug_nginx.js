function buildNginxVars(r) {
    let stringBuffer = []

    // console.error('echo4debug_nginx_var_list:', echo4debug_nginx_var_list)

    Array.from(echo4debug_nginx_var_list).forEach((item) => {
        stringBuffer.push(`${item}=${r.variables[item] ?? ''}`)
    })

    return stringBuffer.join('\n');
}


export default {
    buildNginxVars
}
