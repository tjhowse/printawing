module airfoil(camber_max = 8, camber_position = 4, thickness = 12) {

	//http://www.ppart.de/aerodynamics/profiles/NACA4.html
	
	m = camber_max/100;
	p = camber_position/10;
	t = thickness/100;
	
	pts = 25; // datapoints on each of upper and lower surfaces
	
	function xx(i) = 1 - cos((i-1)*90/(pts-1));
	function yt(i) = t/0.2*(0.2969*pow(xx(i),0.5) - 0.126*xx(i)-0.3516*pow(xx(i),2) + 0.2843*pow(xx(i),3) - 0.1015*pow(xx(i),4));
	function yc(i) = xx(i)<p ? m/pow(p,2)*(2*p*xx(i) - pow(xx(i),2)) : m/pow(1-p,2)*(1 - 2*p + 2*p*xx(i) - pow(xx(i),2));
	function xu(j) = xx(j) - yt(j)*(sin(atan((yc(j)-yc(j-1))/(xx(j)-xx(j-1)))));
	function yu(j) = yc(j) + yt(j)*(cos(atan((yc(j)-yc(j-1))/(xx(j)-xx(j-1)))));
	function xl(j) = xx(j) + yt(j)*(sin(atan((yc(j)-yc(j-1))/(xx(j)-xx(j-1)))));
	function yl(j) = yc(j) - yt(j)*(cos(atan((yc(j)-yc(j-1))/(xx(j)-xx(j-1)))));

	polygon( points=[ 
 	// upper side front-to-back
	[0,0],[xu(2),yu(2)],[xu(3),yu(3)],[xu(4),yu(4)],[xu(5),yu(5)],[xu(6),yu(6)],[xu(7),yu(7)],[xu(8),yu(8)],[xu(9),yu(9)],[xu(10),yu(10)],[xu(11),yu(11)],[xu(12),yu(12)],[xu(13),yu(13)],[xu(14),yu(14)],[xu(15),yu(15)],[xu(16),yu(16)],[xu(17),yu(17)],[xu(18),yu(18)],[xu(19),yu(19)],[xu(20),yu(20)],[xu(21),yu(21)],[xu(22),yu(22)],[xu(23),yu(23)],[xu(24),yu(24)],[xu(25),yu(25)],
	// lower side back to front
	[xl(25),yl(25)],[xl(24),yl(24)],[xl(23),yl(23)],[xl(22),yl(22)],[xl(21),yl(21)],[xl(20),yl(20)],[xl(19),yl(19)],[xl(18),yl(18)],[xl(17),yl(17)],[xl(16),yl(16)],[xl(15),yl(15)],[xl(14),yl(14)],[xl(13),yl(13)],[xl(12),yl(12)],[xl(11),yl(11)],[xl(10),yl(10)],[xl(9),yl(9)],[xl(8),yl(8)],[xl(7),yl(7)],[xl(6),yl(6)],[xl(5),yl(5)],[xl(4),yl(4)],[xl(3),yl(3)],[xl(2),yl(2)],
	] ); 
}

chord_length = 50;
height = 20;
rib_depth = 1;
skin_depth = 1;
$fn = 10;

module wing_shape()
{
	af_1 = 6;
	af_2 = 3;
	af_3 = 13;
	
	linear_extrude(height=height) scale([chord_length,chord_length,chord_length]) airfoil(af_1,af_2,af_3);
	
}

module wing_void()
{
	block_x = 70; // Manually tweak these until the wing object is entirely enclosed by the block, with at least one open end.
	block_y = 20;
	block_z = 20;
	
	difference()
	{
		translate([-block_x/4,-block_y/2,0]) cube([block_x,block_y,block_z]);
		wing_shape();
	}
}

module wing_void_sum(depth)
{
	intersection()
	{
		wing_shape();
		minkowski()
		{
			wing_void();
			sphere(r=depth);
		}
	}			
}

module wing_ribs()
{
	intersection()
	{
		wing_void_sum(rib_depth+skin_depth);
		rotate([0,0,90]) lattice();
	}
}

module lattice()
{
	thickness = 1;
	spacing = 10;
	
	for (i = [-1:10])
	{
		for (j = [-1:10])
		{
			translate([0,j*spacing,i*spacing]) rotate([45,0,0]) cube([100,100,thickness],true);
			translate([0,j*spacing,i*spacing]) rotate([-45,0,0]) cube([100,100,thickness],true);
		}
	}
}

module wing()
{
	union()
	{
		// Skin
		wing_void_sum(skin_depth);
		wing_ribs();
	}
}

wing();