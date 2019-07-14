		precision highp float;

#define cx 0.37742050900124013;
#define cy 0.6057686323765665;
#define epsilon 0.0001
#define steps 1000

#define scalex 100.0
#define scaley 100.0
		
#define trx 0.5
#define try 0.0



 // ***** noise code 
 // Created by inigo quilez - iq/2013
 // License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
 
float hash( float n )
{
    return fract(sin(n)*43758.5453123);
}


float noise(vec2 x )
{
    vec2 p = floor(x);
    vec2 f = fract(x);

    f = f*f*(3.0-2.0*f);

    float n = p.x + p.y*57.0;

    float res = mix(mix( hash(n+  0.0), hash(n+  1.0),f.x),
                    mix( hash(n+ 57.0), hash(n+ 58.0),f.x),f.y);

    return res;
}

        
// * ****************************************************************** */

        float fbm(vec2 p) {

          float f = 0.0;
          f  = 0.5000*noise( p ); p = p*2.0;
          f += 0.2500*noise( p ); p = p*2.0;
          f += 0.1250*noise( p ); p = p*2.0;
          f += 0.0625*noise( p );
          f /= 0.9375;

          return f;
        }

        vec2 f(vec2 z,vec2 c) {
            
            
            float x = (z.x * z.x - z.y * z.y) - z.x + c.x;
            float y = (z.y * z.x + z.x * z.y) - z.y + c.y;

            return vec2(x,y);
        }
        
        float SIC(int p, int N,int M, vec2 z) {
            // smooth iteration count, see http://jussiharkonen.com/gallery/coloring-techniques/
            // p is the max degree of the polynom used in our julia set definition
            // N is iteration when reaching bailout value
            // M is bailout value
            
            float r = length(z);
            return (float(N)+1.0+( log((log(float(M)))/log(r)) / log(float(p)) ));
        }
        
        vec4 myColor(float index, float dist, float dist2, float dist3) {
            float seuil1=0.100;
            float seuil2=0.200;
            float seuil3=0.900;
            float blurp=8.0;
            vec3 color;
            
            index*=index;
            vec3 grey  = vec3(180.0/255.0, 212.0/255.0, 229.0/255.0);
            vec3 dark  = vec3( 40.0/255.0,  48.0/255.0,  64.0/255.0) ;
            vec3 yellow= vec3(212.0/255.0, 212.0/255.0, 145.0/255.0);
            vec3 glgl  = vec3(150.0/255.0, 50.0/255.0,  0.0/255.0);
            vec3 red  = vec3( 212.0/255.0, 30.0/255.0, 0.0/255.0);
            
            //4 levels color shading
            color  = mix ( grey,   dark,  smoothstep(   0.0, seuil1, index ));
            color  = mix (color, yellow,  smoothstep(seuil1, seuil2, index ));
            color  = mix (color,    glgl,  smoothstep(seuil2, seuil3, index ));
            color  = mix (color,    red, smoothstep(seuil3,    1.0, index ));
            
            //point orbit traping
            color  *= mix ( (.5, .0, .0), (1.0, 1.0, 1.0), smoothstep(.0, blurp, blurp-dist ));
            color  *= mix ( (.0, .5, .0), (1.0, 1.0, 1.0), smoothstep(.0, blurp, blurp-dist2 ));
            color  *= mix ( (.0, .0, .5), (1.0, 1.0, 1.0), smoothstep(.0, blurp, blurp-dist3 ));
            
            //color /= 2.0;   
                                                        
            return vec4(color,1.0);
        }

        void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
			float time = ( 60.0 + iTime)*.01 + 0.5*iMouse.x/iResolution.x;
            
            float sx=float(iResolution.x);
            float sy=float(iResolution.y);
            vec2 z,zn;
            vec2 orbitPoint = vec2(1.5,1.2);
            vec2 orbitPoint2 = vec2(-0.7,1.5);
            vec2 orbitPoint3 = vec2(1.8,-1.2);
            float dist=1000000000.0;
            float dist2=1000000000.0;
            float dist3=1000000000.0;
            float idx;
            // convert gl_fragcoord to mathematical coords
            
			
            z.x = (fragCoord.x - sx/2.0)/scalex+trx;
            z.y = (fragCoord.y - sy/2.0)/scaley+try;

			//from iq "julia" https://www.shadertoy.com/view/4dfGRn
			vec2 cc = 1.1*vec2( 0.5*cos(0.5 * time) - 0.25*cos(1.0 * time), 
	                            0.5*sin(0.5 * time) - 0.25*sin(1.0 * time) );
			
			
            fragColor = vec4(0.0,0.0,0.0,1.0);
            // loop until found or too long
            for (int n=0; n<500; n++) {
                zn=f(z,cc); 
                dist = min( dist, length(zn-orbitPoint));
                dist2 = min( dist2, length(zn-orbitPoint2)); 
                dist3 = min( dist3, length(zn-orbitPoint3));
                
                if ( (zn.x*zn.x+zn.y*zn.y)>64.0 ) {
                    // outside julia
                    idx = SIC(2, n, 2, zn) /250.0; // * ( 1.0 +(fbm(z*16.0)/4.0) ); 
                    clamp(idx,.0,1.0);                    
                    fragColor = myColor( idx, dist, dist2, dist3);                                                     
                    break;
                }
                   
                if ( distance(z,zn) < 0.005 ) {
                    //inside julia set
                    fragColor = myColor( SIC(2, n, 2, zn) /250.0, dist, dist2, dist3);                           
                    break;
                }            
                z=zn;
            } //for
          
             
        }   // main
