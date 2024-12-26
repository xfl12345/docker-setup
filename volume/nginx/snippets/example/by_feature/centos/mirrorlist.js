// mirrorlist.js

function generateMirrorlist(r) {
    // 获取查询参数
    const releasever = r.args.releasever || "7";
    const repo = r.args.repo || "os";
    const basearch = r.args.basearch || "x86_64";

    // 定义镜像列表
    // http://mirrorlist.centos.org/?release=7&arch=x86_64&repo=os&infra=container
    // https://mirrors.aliyun.com/centos/7/os/x86_64/
    const mirrors = [
        `https://mirrors.aliyun.com/centos/${releasever}/${repo}/${basearch}/`
    ];

    r.status = 200;
    // 设置响应头
    r.headersOut['Content-Type'] = 'text/plain';
    r.headersOut['Content-Disposition'] = 'inline; filename="mirrorlist"';

    // 发送响应体
    r.sendHeader();
    mirrors.forEach(mirror => r.send(mirror + '\n'));
    r.finish();
}

export default {
    generateMirrorlist
}
