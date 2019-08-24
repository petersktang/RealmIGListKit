#  RealmIGListKit
Sample code to handle RealmChangeset updates within IGListKit in a Multi-Section CollectionView. The code is able to allow the same realm change source hitting multiple CollectionView sections at the same time without getting into integrity errors.

## Problem 1: 
Realm objects are mutable, and has to copied into an array before it can be used in IGListKit.

## Problem 2: 
When changes base on the same data source needs to be reflected onto multiple Collection View sections, this change has to happen at the same time and within the same batch update block.

# Reference
https://github.com/RxSwiftCommunity/RxRealmDataSources 


