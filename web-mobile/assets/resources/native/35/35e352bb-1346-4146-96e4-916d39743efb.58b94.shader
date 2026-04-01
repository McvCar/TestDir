// Grayscale Gradient Shader
// 从左到右由灰色渐变到彩色
// Cocos Creator 2.4

cc.exports.GrayscaleGradientShader = {
    name: "GrayscaleGradientShader",
    params: [
        { name: "u_progress", type: cc.renderer.engine.PARAM_FLOAT },
        { name: "u_texture", type: cc.renderer.engine.PARAM_TEXTURE_2D }
    ],
    vs: `
        attribute vec4 a_position;
        attribute vec2 a_uv0;
        attribute vec4 a_color;
        uniform mat4 cc_matViewProj;
        varying vec2 v_uv0;
        varying vec4 v_color;
        void main () {
            gl_Position = cc_matViewProj * a_position;
            v_uv0 = a_uv0;
            v_color = a_color;
        }
    `,
    fs: `
        precision highp float;
        uniform float u_progress;
        uniform sampler2D u_texture;
        varying vec2 v_uv0;
        varying vec4 v_color;
        float rgb2gray(vec3 rgb) {
            return dot(rgb, vec3(0.299, 0.587, 0.114));
        }
        void main () {
            vec4 color = v_color * texture2D(u_texture, v_uv0);
            if (color.a < 0.5) discard;
            float gray = rgb2gray(color.rgb);
            vec3 grayscale = vec3(gray, gray, gray);
            float gradient = smoothstep(0.0, 1.0, v_uv0.x);
            float factor = step(gradient, u_progress);
            vec3 finalColor = mix(grayscale, color.rgb, factor);
            gl_FragColor = vec4(finalColor, color.a);
        }
    `
};

cc.loader.register({
    extensions: [".shader"],
    loader: function (realUrl, url, res) {
        return new Promise(function (resolve, reject) {
            cc.loader.load(realUrl, function (err, data) {
                if (err) {
                    reject(err);
                } else {
                    var shaderStr = typeof data === 'string' ? data : data.toString();
                    var shaderObj = JSON.parse(shaderStr);
                    var shader = new cc.Shader(shaderObj.name, shaderObj.params, shaderObj.chunks);
                    resolve(shader);
                }
            });
        });
    }
});
