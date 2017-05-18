var path = require('path'),
    config;

config = {
    production: {
        url: 'http://me.wangyan.org',
        mail: {
            transport: 'SMTP',
            from: '"WangYan" <noreply@wangyan.org>',
            options: {
                host: "smtp.exmail.qq.com",
                secureConnection: true,
                port: 465,
                auth: {
                    user: 'noreply@wangyan.org',
                    pass: 'Noreply123'
                }
            }
        },
        database: {
            client: 'sqlite3',
            connection: {
                filename: path.join(process.env.GHOST_CONTENT, '/data/ghost.db')
            },
            debug: false
        },
        server: {
            host: '0.0.0.0',
            port: '2368'
            //socket: {
            //    path: '/opt/ghost/socket.sock',
            //    permissions: '0666'
            //}
        },
        paths: {
            contentPath: path.join(process.env.GHOST_CONTENT, '/')
        }
    }
};

module.exports = config;