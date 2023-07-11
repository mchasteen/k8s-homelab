#!/bin/bash
helm repo add fermosit https://harbor.fermosit.es/chartrepo/library
helm repo update
helm install minetest-01 -n minetest --create-namespace -f ./values-minetest.yaml fermosit/minetest
