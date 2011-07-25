#!/usr/bin/perl -w

# Copyright 2011 Magnus Enger
#
# This file is part of msync.
#
# msync is free software; you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.
#
# msync is distributed in the hope that it will be useful, but WITHOUT ANY
# WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
# A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with msync; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

use File::Slurp;
use strict;

my $origdir = '/media/My Passport/flac/pop/';
my $oggdir  = '/home/magnus/Musikk/pop/';
my $mp3dir  = '/media/My Passport/mp3/pop/';
my $trackcount = 0;

# Artists
my @artists = read_dir($origdir);
foreach my $artist (@artists) {

  print "$artist\n";
  my $artistdir = $origdir . $artist;
  # Check that this is a dir
  next if !-d $artistdir;
  
  # Target artist-dir
  my $oggartistdir = $oggdir . $artist;
  if (!-d $oggartistdir) {
    mkdir $oggartistdir;
  }
  my $mp3artistdir = $mp3dir . $artist;
  if (!-d $mp3artistdir) {
    mkdir $mp3artistdir;
  }
  
  # Albums
  my @albums = read_dir($artistdir);
  foreach my $album (@albums) {
  
    print "  $album\n";
    my $albumdir = $artistdir . '/' . $album;
    # Check that this is a dir
    next if !-d $albumdir;
    
    # Target artist-dir
    my $oggalbumdir = $oggartistdir . '/' . $album;
    if (!-d $oggalbumdir) {
      mkdir $oggalbumdir;
    }
    my $mp3albumdir = $mp3artistdir . '/' . $album;
    if (!-d $mp3albumdir) {
      mkdir $mp3albumdir;
    }
    # Tracks
    my @tracks = read_dir($albumdir);
    foreach my $track (@tracks) {
    
      print "  - $track";
      my $oldtrack = $albumdir . '/' . $track;
      $trackcount++;
      
      # Transcode or copy files to new location
      if ($track =~ m/(.*)\.flac/i) {
        # Transcode to ogg
        my $oggtrack = $oggalbumdir . '/' . $1 . '.ogg';
        if ( !-e $oggtrack ) {
          `ffmpeg -loglevel quiet -i "$oldtrack" -acodec libvorbis -aq 60 "$oggtrack"`;
        } else {
          print " - skipped"
        }
        # Transcode to mp3
        my $mp3track = $mp3albumdir . '/' . $1 . '.mp3';
        if ( !-e $mp3track ) {
        #   `ffmpeg -loglevel quiet -i "$oldtrack" -acodec mp3 -ac 2 "$mp3track"`;
        } else {
          print " - skipped"
        }
      } else {
        # Copy
        my $oggcptrack = $oggalbumdir . '/' . $track;
        if ( !-e $oggcptrack ) {
          `cp "$oldtrack" "$oggcptrack"`;
        } else {
          print " - skipped"
        }
        my $mp3cptrack = $mp3albumdir . '/' . $track;
        if ( !-e $mp3cptrack ) {
          `cp "$oldtrack" "$mp3cptrack"`;
        } else {
          print " - skipped"
        }

      }
      print "\n";
    
    }
  
  }

}

print "\nTracks: $trackcount\n";
