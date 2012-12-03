#!/usr/bin/perl -w
use strict;
use Cwd;

$ENV{CMAKE_PREFIX_PATH}='/usr';
$ENV{MACOSX_DEPLOYMENT_TARGET}='10.6';

system("cmake --version") && die "Cmake not found. Please install it first";
my $xcode_ver = `xcodebuild -version`;
print $xcode_ver;
#if ($xcode_ver !~ /4\.2\.1/) { die "Xcode 4.2.1 is required"; }

my $top_dir = getcwd();

unless(-d "btlauncher")
{
	system("git clone git\@github.com:kzahel/btlauncher.git") && die "Failed to clone btlauncher";
}
else
{
	chdir("btlauncher");
	system("git pull") && die "Failed to pull btlauncher";
	chdir($top_dir);
}

unless(-d "firebreath")
{
	system("git clone git://github.com/firebreath/FireBreath.git -b firebreath-1.6 firebreath") && die "Failed to clone";
	chdir("firebreath");
	system("git submodule update --init") && die "Failed to init submodules";
	system("patch --strip 1 < ../firebreath.patch") && die "Failed to apply patch";
	chdir($top_dir)
}
else
{
	chdir("firebreath");
	system("git pull") && die "Failed to pull firebreath";
	chdir($top_dir)
}

my @plugins = (
	{
		config=>'SharePluginConfig.cmake',
		name=>'SoShare',
		cert=>'Developer ID Application: Gyre'
	},
	{
		config=>'TorquePluginConfig.cmake',
		name=>'Torque',
		cert=>'Developer ID Application: BitTorrent'
	}
);

for my $p(@plugins)
{
	chdir("btlauncher");
	system("rm -f PluginConfig.cmake");
	system("cp $p->{config} PluginConfig.cmake");
	chdir("../firebreath");

	system("rm -rf projects build");
	mkdir("projects");
	chdir("projects");
	system("ln -s ../../btlauncher");
	chdir("..");
	system("./prepmac.sh") && die "Failed to run prepmac.sh";
	chdir("build");
	system("xcodebuild -configuration Release") && die "Build failed";
	system("codesign -f -v -s  '$p->{cert}' projects/$p->{name}/Release/$p->{name}.plugin");
	system("cp -r projects/$p->{name}/Release/$p->{name}.plugin $top_dir/");
	chdir($top_dir);
}
