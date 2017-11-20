// ViewWolf.js

import alfrid, { GL } from 'alfrid';
import Assets from './Assets';
import fs from 'shaders/wolf.frag';

class ViewWolf extends alfrid.View {
	
	constructor() {
		super(null, fs);
		this.fps = 32;
		this.frame = 0;

		this.mtx = mat4.create();
		this.mtxModel = mat4.create();
		const s = 2;
		mat4.scale(this.mtxModel, this.mtxModel, vec3.fromValues(s, s, s));
		mat4.translate(this.mtxModel, this.mtxModel, vec3.fromValues(-.3, .4, 0.0));
		mat4.rotateY(this.mtxModel, this.mtxModel, Math.PI / 2);
	}


	_init() {
		// this.mesh;
		this.update();

	}


	update() {
		if(!this.mesh) {
			this.frame = 0;
		} else {
			this.frame ++;	
		}
		
		if(this.frame >= 16) {
			this.frame = 0;
		}

		let index = (this.frame+1).toString();
		if(index.length == 1) {
			index = '0' + index;
		}

		this.mesh = Assets.get(`wolf${index}`);

		setTimeout(()=> this.update(), 1000/this.fps);
	}


	render() {
		GL.rotate(this.mtxModel);

		this.shader.bind();
		this.shader.uniform("uLightPos", "vec3", params.lightPosition);
		GL.draw(this.mesh);

		GL.rotate(this.mtx);
	}


}

export default ViewWolf;