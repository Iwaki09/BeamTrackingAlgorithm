% データの作成
x = linspace(0, 10, 100); % x軸の値を生成

% Optimal曲線のデータ
y_optimal = sin(x);

% Beam Tracking (2way)曲線のデータ
y_beam_tracking = cos(x);

% プロット
figure;
plot(x, y_optimal, 'b-', 'LineWidth', 2, 'DisplayName', 'Optimal'); % 青色でOptimal曲線をプロット
hold on;
plot(x, y_beam_tracking, 'r--', 'LineWidth', 2, 'DisplayName', 'Beam Tracking (2way)'); % 赤色でBeam Tracking曲線をプロット
hold off;

% ラベルの追加
xlabel('X軸ラベル');
ylabel('Y軸ラベル');
title('二つの曲線のプロット');

% 凡例の追加
legend('Location', 'Best');

% グリッドの表示
grid on;

