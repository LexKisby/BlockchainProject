part of page_classes;

class AuctionContent extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);

    return ListView.builder(
      itemBuilder: (context, position) {
        return MarketRow();
      },
      itemCount: info.data.marketMonstersForAuction.length,
    );
  }
}

class MarketRow extends StatelessWidget {
  build(BuildContext context) {
    return ListTile();
  }
}

class DonorContent extends ConsumerWidget {
  @override
  build(BuildContext context, ScopedReader watch) {
    final info = watch(myEthDataProvider);

    return ListView.builder(
      itemBuilder: (context, position) {
        return MarketRow();
      },
      itemCount: info.data.marketMonstersForDonor.length,
    );
  }
}
